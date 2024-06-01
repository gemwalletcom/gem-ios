import Foundation
import SwiftUI
import CoreImage.CIFilterBuiltins

public struct QRCodeGenerator {
    private let context = CIContext()
    
    public init() {}

    public func generate(from string: String) -> UIImage {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        return UIImage()
    }
}

struct QRCodeGenerator_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            Image(uiImage: QRCodeGenerator().generate(from: "test"))
                .resizable()
                .frame(width: 200, height: 200)
        }
    }
}
