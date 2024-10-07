import Foundation
import SwiftUI
import CoreImage.CIFilterBuiltins

public struct QRCodeGenerator {
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()

    public init() {}

    public func generate(
        from string: String,
        size: CGSize = CGSize(width: 240, height: 240),
        logo: UIImage? = nil,
        logoScale: CGFloat = 0.3
    ) -> UIImage {
        filter.message = Data(string.utf8)
        filter.correctionLevel = "H"

        guard let outputImage = filter.outputImage else { return UIImage() }

        let transform = CGAffineTransform(
            scaleX: size.width / outputImage.extent.size.width,
            y: size.height / outputImage.extent.size.height
        )
        let scaledImage = outputImage.transformed(by: transform)

        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return UIImage()
        }

        let qrCodeImage = UIImage(cgImage: cgImage)

        if let logo = logo {
            let renderer = UIGraphicsImageRenderer(size: qrCodeImage.size)
            let combinedImage = renderer.image { context in
                qrCodeImage.draw(in: CGRect(origin: .zero, size: qrCodeImage.size))

                let logoSize = CGSize(
                    width: size.width * logoScale,
                    height: size.height * logoScale
                )
                let logoOrigin = CGPoint(
                    x: (qrCodeImage.size.width - logoSize.width) / 2,
                    y: (qrCodeImage.size.height - logoSize.height) / 2
                )
                logo.draw(in: CGRect(origin: logoOrigin, size: logoSize))
            }

            return combinedImage
        }
        return qrCodeImage
    }
}

#Preview {
    Image(uiImage: QRCodeGenerator().generate(from: "test"))
        .resizable()
        .frame(width: 200, height: 200)
}
