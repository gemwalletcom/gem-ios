// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import UIKit

public extension UIImage {
    /// Enum representing different levels of JPEG compression quality.
    enum JPEGQuality: CGFloat {
        /// Lowest quality (maximum compression) - 0.0
        case lowest  = 0
        /// Low quality - 0.25
        case low     = 0.25
        /// Medium quality - 0.5
        case medium  = 0.5
        /// High quality - 0.75
        case high    = 0.75
        /// Highest quality (least compression) - 1.0
        case highest = 1
    }

    /// Converts the `UIImage` to JPEG data with the specified compression quality.
    ///
    /// - Parameter jpegQuality: The desired quality level for JPEG compression.
    /// - Returns: A `Data?` object containing the JPEG representation of the image,
    ///            or `nil` if the conversion fails.
    func compress(_ jpegQuality: JPEGQuality) -> Data? {
        jpegData(compressionQuality: jpegQuality.rawValue)
    }
    
    /// Resizes the image to fit within the specified width while maintaining its aspect ratio.
    ///
    /// - Parameter targetWidth: The desired width of the resized image in points.
    /// - Returns: A new `UIImage` instance with the adjusted size, or `nil` if resizing fails.
    ///
    /// ### Example Usage:
    /// ```swift
    /// if let resizedImage = originalImage.resizeImageAspectFit(targetWidth: 300) {
    ///     imageView.image = resizedImage
    /// }
    /// ```
    func resizeImageAspectFit(targetWidth: CGFloat) -> UIImage? {
        let scale = targetWidth / size.width
        let targetHeight = size.height * scale
        let targetSize = CGSize(width: targetWidth, height: targetHeight)

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }}
