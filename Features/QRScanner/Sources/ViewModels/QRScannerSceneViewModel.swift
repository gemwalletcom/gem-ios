// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import PhotosUI

@Observable
@MainActor
final class QRScannerSceneViewModel {
    var scannerState: QRScannerState
    var imageState: ImageState
    var selectedPhoto: PhotosPickerItem?
    var isScannerReady: Bool = false

    let resources: QRScannerResources

    init(scannerState: QRScannerState, imageState: ImageState, resources: QRScannerResources) {
        self.scannerState = scannerState
        self.imageState = imageState
        self.resources = resources
    }

    var overlayConfig: QRScannerDisplayConfiguration { .default }
    var isScanning: Bool { scannerState == .scanning }
}

// MARK: - Business Logic

extension QRScannerSceneViewModel {
    func onChangeScannerReadyStatus(_: Bool, _: Bool) {
        refreshScannerState()
    }
    
    func refreshScannerState() {
        do {
            switch scannerState {
            case .idle:
                try QRScannerViewWrapper.checkDeviceQRScanningSupport()
                if isScannerReady {
                    scannerState = .scanning
                }
            case .failure:
                // Reset scanner state to allow retrying after a failure
                try QRScannerViewWrapper.checkDeviceQRScanningSupport()
            case .scanning:
                break
            }
        } catch {
            refreshScannerState(error: error)
        }
    }

    func refreshScannerState(error: Error) {
        if let error = error as? QRScannerError {
            scannerState = .failure(error: error)
        } else {
            scannerState = .failure(error: .unknown(error))
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
