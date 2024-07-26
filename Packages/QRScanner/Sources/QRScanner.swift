// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import PhotosUI

enum QRScannerState {
    case idle
    case failure(error: QRScannerError)
    case scanning
}

enum ImageState: Equatable {
    case empty
    case success(UIImage)
    case failure(Error)

    static func == (lhs: ImageState, rhs: ImageState) -> Bool {
        switch (lhs, rhs) {
        case (.empty, .empty):
            return true
        case (.success(let lhsImage), .success(let rhsImage)):
            return lhsImage.hashValue == rhsImage.hashValue
        case (.failure(let lhsError), .failure(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

@Observable
@MainActor
class QRScanner {
    var scannerState: QRScannerState
    var imageState: ImageState
    var selectedPhoto: PhotosPickerItem?

    init(scannerState: QRScannerState, imageState: ImageState) {
        self.scannerState = scannerState
        self.imageState = imageState
    }
}

// MARK: - Business Logic

extension QRScanner {
    func refreshScannerState() {
        do {
            try QRScannerViewWrapper.checkDeviceQRScanningSupport()
            scannerState = .scanning
        } catch {
            refreshScannerState(error: error)
        }
    }

    func refreshScannerState(error: Error) {
        if let error = error as? QRScannerError {
            scannerState = .failure(error: error)
        } else {
            scannerState = .failure(error: .unexpected(error))
        }
    }

    func process(photoItem: PhotosPickerItem) async {
        imageState = .empty
        do {
            if let data = try await photoItem.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data, scale: 1.0) {
                imageState = .success(uiImage)
            } else {
                imageState = .empty
            }
        } catch {
            imageState = .failure(error)
        }
    }

    func retriveQR(image: UIImage) throws -> String {
        try QRImageDecoder.process(image)
    }
}
