// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import VisionKit

@MainActor
struct QRScannerViewWrapper {
    typealias ScanResult = (Result<String, Error>) -> Void

    private var scanResult: ScanResult
    private var dataScannerVC = DataScannerViewController(
        recognizedDataTypes: [.barcode(symbologies: [.qr])],
        qualityLevel: .balanced,
        recognizesMultipleItems: false,
        isHighFrameRateTrackingEnabled: true,
        isGuidanceEnabled: false,
        isHighlightingEnabled: false
    )

    @Binding var isScannerReady: Bool

    init(isScannerReady: Binding<Bool>, scanResult: @escaping ScanResult) {
        self.scanResult = scanResult
        _isScannerReady = isScannerReady
    }

    func startScanning() {
        guard !dataScannerVC.isScanning else { return }
        do {
            try dataScannerVC.startScanning()
            Task {
                self.isScannerReady = true
            }
        } catch {
            scanResult(.failure(QRScannerError.unknown(error)))
            isScannerReady = false
        }
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
        dataScannerVC.delegate = context.coordinator
        return dataScannerVC
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}

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
            parent.startScanning()
        }

        func didAddItem(item: RecognizedItem) {
            guard case .barcode(let barcode) = item else { return }

            if let code = barcode.payloadStringValue {
                parent.scanResult(.success(code))
            } else {
                parent.scanResult(.failure(QRScannerError.decoding))
            }
        }
    }
}

// MARK: - DataScannerViewControllerDelegate

extension QRScannerViewWrapper.Coordinator: DataScannerViewControllerDelegate {
    func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
        if let item = addedItems.first {
            didAddItem(item: item)
        }
    }
    func dataScanner(
        _ dataScanner: DataScannerViewController,
        becameUnavailableWithError error: DataScannerViewController.ScanningUnavailable
    ) {
        parent.scanResult(.failure(error))
    }
}
