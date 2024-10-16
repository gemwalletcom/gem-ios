import Foundation
import SwiftUI
import CoreImage.CIFilterBuiltins

public actor QRCodeGenerator {
    private static let context = CIContext(options: nil)
    private static let filter = CIFilter.qrCodeGenerator()

    public init() {}

    public func generate(
        from string: String,
        size: CGSize,
        logo: UIImage? = nil,
        displayScale: CGFloat,
        logoQRScale: CGFloat = 0.26,
        logoBackgroundScale: CGFloat = 0.7,
        backgroundColor: UIColor = .white,
        cornerRadius: CGFloat = 12
    ) -> UIImage? {
        guard let qrCodeImage = createQRCode(from: string, size: size, displayScale: displayScale) else {
            return nil
        }

        return logo != nil ? addLogo(
            to: qrCodeImage,
            logo: logo!,
            displayScale: displayScale,
            logoQRScale: logoQRScale,
            logoBackgroundScale: logoBackgroundScale,
            backgroundColor: backgroundColor,
            cornerRadius: cornerRadius
        ) : qrCodeImage
    }

    private func createQRCode(from string: String, size: CGSize, displayScale: CGFloat) -> UIImage? {
        let data = Data(string.utf8)
        QRCodeGenerator.filter.setValue(data, forKey: "inputMessage")
        QRCodeGenerator.filter.setValue("H", forKey: "inputCorrectionLevel")

        guard let outputImage = QRCodeGenerator.filter.outputImage else { return nil }

        let scaleX = size.width * displayScale / outputImage.extent.size.width
        let scaleY = size.height * displayScale / outputImage.extent.size.height
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        guard let cgImage = QRCodeGenerator.context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage, scale: displayScale, orientation: .up)
    }

    private func addLogo(
        to qrCodeImage: UIImage,
        logo: UIImage,
        displayScale: CGFloat,
        logoQRScale: CGFloat,
        logoBackgroundScale: CGFloat,
        backgroundColor: UIColor,
        cornerRadius: CGFloat
    ) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = displayScale
        let renderer = UIGraphicsImageRenderer(size: qrCodeImage.size, format: format)

        return renderer.image { context in
            qrCodeImage.draw(in: CGRect(origin: .zero, size: qrCodeImage.size))

            let backgroundSize = CGSize(width: qrCodeImage.size.width * logoQRScale,
                                        height: qrCodeImage.size.height * logoQRScale)
            let backgroundOrigin = CGPoint(x: (qrCodeImage.size.width - backgroundSize.width) / 2,
                                           y: (qrCodeImage.size.height - backgroundSize.height) / 2)
            let backgroundRect = CGRect(origin: backgroundOrigin, size: backgroundSize)

            let backgroundPath = UIBezierPath(roundedRect: backgroundRect, cornerRadius: cornerRadius)
            backgroundColor.setFill()
            backgroundPath.fill()

            let logoMaxSize = CGSize(width: backgroundRect.width * logoBackgroundScale,
                                     height: backgroundRect.height * logoBackgroundScale)
            let scaledLogoSize = aspectFitSize(for: logo.size, within: logoMaxSize)

            let logoOrigin = CGPoint(x: backgroundRect.midX - scaledLogoSize.width / 2,
                                     y: backgroundRect.midY - scaledLogoSize.height / 2)
            let logoRect = CGRect(origin: logoOrigin, size: scaledLogoSize)

            logo.draw(in: logoRect)
        }
    }

    private func aspectFitSize(for originalSize: CGSize, within maxSize: CGSize) -> CGSize {
        let widthRatio = maxSize.width / originalSize.width
        let heightRatio = maxSize.height / originalSize.height
        let scale = min(widthRatio, heightRatio)
        return CGSize(width: originalSize.width * scale, height: originalSize.height * scale)
    }
}
