// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI

public struct ToastMessage: Identifiable, Equatable {
    public static let toastDuration: Double = 2

    public var id: String { title + image }

    public let title: String
    public let image: String
    public let duration: Double
    public let tapToDismiss: Bool

    public init(
        title: String,
        image: String,
        duration: Double = Self.toastDuration,
        tapToDismiss: Bool = true
    ) {
        self.title = title
        self.image = image
        self.duration = duration
        self.tapToDismiss = tapToDismiss
    }
}

extension ToastMessage {
    static func empty() -> ToastMessage {
        ToastMessage(title: "", image: "")
    }
}
