// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import QRScanner
import Style

struct ScanQRCodeNavigationStack: View {
    var action: ((String) -> Void)
    private let resources = QRScannerResources()

    var body: some View {
        NavigationStack {
            QRScannerView(resources: resources, action: action)
                .navigationTitle(Localized.Wallet.scanQrCode)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - LocalizedQRError

extension QRScannerError: LocalizedQRError {
    public var titleImage: (title: String, systemImage: String)? {
        switch self {
        case .notSupported:
            (Localized.Errors.notSupported, SystemImage.clear)
        case .permissionsNotGranted:
            (Localized.Errors.permissionsNotGranted, SystemImage.lock)
        case .decoding:
            (Localized.Errors.decoding, SystemImage.errorOccurred)
        case .unexpected:
            (Localized.Errors.unexpected, SystemImage.errorOccurred)
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
        case .unexpected:
            Localized.Errors.unexpectedTryAgain
        }
    }
}
