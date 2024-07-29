// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import PhotosUI

@Observable
@MainActor
class QRScannerViewModel {
    var scannerState: QRScannerState
    var imageState: ImageState
    var selectedPhoto: PhotosPickerItem?

    let resources: QRScannerResourcesProviding

    init(scannerState: QRScannerState, imageState: ImageState, resources: QRScannerResourcesProviding) {
        self.scannerState = scannerState
        self.imageState = imageState
        self.resources = resources
    }
}

// MARK: - Business Logic

extension QRScannerViewModel {
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

    func retrieveQRCode(image: UIImage) throws -> String {
        try QRImageDecoder.process(image)
    }
}
