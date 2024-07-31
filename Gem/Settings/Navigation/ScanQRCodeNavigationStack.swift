// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import QRScanner
import Style

struct ScanQRCodeNavigationStack: View {
    var action: ((String) -> Void)
    private let resources: QRScannerResources = QRScanResources()

    var body: some View {
        NavigationStack {
            QRScannerView(resources: resources, action: action)
                .navigationTitle(Localized.Wallet.scanQrCode)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - LocalizedQRCodeError

extension QRScannerError: LocalizedQRCodeError {
    public var titleImage: ErrorTitleImage? {
        switch self {
        case .notSupported:
            ErrorTitleImage(title: Localized.Errors.notSupported, systemImage: SystemImage.clear)
        case .permissionsNotGranted:
            ErrorTitleImage(title: Localized.Errors.permissionsNotGranted, systemImage: SystemImage.lock)
        case .decoding:
            ErrorTitleImage(title: Localized.Errors.decoding, systemImage: SystemImage.errorOccurred)
        case .unknown:
            ErrorTitleImage(title: Localized.Errors.unknown, systemImage: SystemImage.errorOccurred)
        }
    }

    public var errorDescription: String? {
        switch self {
        case .notSupported:
            Localized.Errors.notSupportedQr
        case .permissionsNotGranted:
            Localized.Errors.cameraPermissionsNotGranted
        case .decoding:
            Localized.Errors.decodingQr
        case .unknown:
            Localized.Errors.unknown
        }
    }
}
