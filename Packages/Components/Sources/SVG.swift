// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Darwin
import UIKit

extension UnsafeMutableRawPointer: @unchecked @retroactive Sendable {}
extension UnsafeRawPointer: @unchecked @retroactive Sendable {}

private struct CoreSVGSymbols {
    static let CGSVGDocumentRetain: (@convention(c) (CGSVGDocument?) -> Unmanaged<CGSVGDocument>?) = loadSymbol("CGSVGDocumentRetain")
    static let CGSVGDocumentRelease: (@convention(c) (CGSVGDocument?) -> Void) = loadSymbol("CGSVGDocumentRelease")
    static let CGSVGDocumentCreateFromData: (@convention(c) (CFData?, CFDictionary?) -> Unmanaged<CGSVGDocument>?) = loadSymbol("CGSVGDocumentCreateFromData")
    static let CGContextDrawSVGDocument: (@convention(c) (CGContext?, CGSVGDocument?) -> Void) = loadSymbol("CGContextDrawSVGDocument")
    static let CGSVGDocumentGetCanvasSize: (@convention(c) (CGSVGDocument?) -> CGSize) = loadSymbol("CGSVGDocumentGetCanvasSize")

    private static let CoreSVGHandle = dlopen("/System/Library/PrivateFrameworks/CoreSVG.framework/CoreSVG", RTLD_NOW)

    private static func loadSymbol<T>(_ name: String) -> T {
        unsafeBitCast(dlsym(CoreSVGHandle, name), to: T.self)
    }
}

@objc
final class CGSVGDocument: NSObject {}

public final class SVG {
    private let document: CGSVGDocument
    private let size: CGSize

    deinit {
        CoreSVGSymbols.CGSVGDocumentRelease(document)
    }

    public init?(_ data: Data) {
        guard
            let doc = CoreSVGSymbols.CGSVGDocumentCreateFromData(data as CFData, nil)?.takeUnretainedValue()
        else {
            return nil
        }
        let canvas = CoreSVGSymbols.CGSVGDocumentGetCanvasSize(doc)
        guard canvas != .zero else { return nil }
        self.document = doc
        self.size = canvas
    }

    public func renderedUIImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { [weak self] ctx in
            guard let self else { return }
            self.draw(in: ctx.cgContext, target: size)
        }
    }

    private func draw(in context: CGContext, target: CGSize) {
        let scaleFactor = min(target.width / size.width, target.height / size.height)
        context.translateBy(x: 0, y: target.height)
        context.scaleBy(x: 1, y: -1)
        context.concatenate(CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))

        let leftoverX = (target.width / scaleFactor - size.width) / 2
        let leftoverY = (target.height / scaleFactor - size.height) / 2
        context.translateBy(x: leftoverX, y: leftoverY)

        CoreSVGSymbols.CGContextDrawSVGDocument(context, document)
    }
}
