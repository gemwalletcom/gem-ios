// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import VisionKit

@MainActor
struct QRScannerViewWrapper {
    typealias ScanResult = (Result<String, Error>) -> Void

    private var scanResult: ScanResult

    init(scanResult: @escaping ScanResult) {
        self.scanResult = scanResult
    }

    static func checkDeviceQRScanningSupport() throws {
        guard DataScannerViewController.isSupported else {
            throw QRScannerError.notSupported
        }

        guard DataScannerViewController.isAvailable else {
            throw QRScannerError.permissionsNotGranted
        }
    }
}

// MARK: - UIViewControllerRepresentable

extension QRScannerViewWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let dataScannerVC = DataScannerViewController(
            recognizedDataTypes: [.barcode(symbologies: [.qr])],
            qualityLevel: .accurate,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: false,
            isGuidanceEnabled: false,
            isHighlightingEnabled: false
        )
        dataScannerVC.delegate = context.coordinator
        
        try? dataScannerVC.startScanning()

        return dataScannerVC
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        guard !uiViewController.isScanning else { return }

        do {
            try uiViewController.startScanning()
        } catch {
            context.coordinator.parent.scanResult(.failure(QRScannerError.unknown(error)))
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

// MARK: - Coordinator

extension QRScannerViewWrapper {
    @MainActor
    class Coordinator {
        var parent: QRScannerViewWrapper

        init(_ parent: QRScannerViewWrapper) {
            self.parent = parent
        }
    }
}

// MARK: - DataScannerViewControllerDelegate

extension QRScannerViewWrapper.Coordinator: DataScannerViewControllerDelegate {
    func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
        guard case .barcode(let barcode) = item else { return }

        if let code = barcode.payloadStringValue {
            parent.scanResult(.success(code))
        } else {
            parent.scanResult(.failure(QRScannerError.decoding))
        }
    }
}
