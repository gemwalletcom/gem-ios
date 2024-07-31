// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

struct QRImageDecoder {
    static func process(_ image: UIImage) throws -> String {
        guard let ciImage = CIImage(image: image),
              let qrCode = detectQRCode(in: ciImage) else {
            throw QRScannerError.decoding
        }
        return qrCode
    }

    private static func detectQRCode(in image: CIImage) -> String? {
        let detector = CIDetector(
            ofType: CIDetectorTypeQRCode,
            context: nil,
            options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        )
        let features = detector?.features(in: image) as? [CIQRCodeFeature]
        return features?.first?.messageString
    }
}
