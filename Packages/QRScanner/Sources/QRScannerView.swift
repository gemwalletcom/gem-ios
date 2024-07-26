// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import PhotosUI

@MainActor
public struct QRScannerView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss

    @State private var model: QRScanner

    private let textProvider: QRScannerTextProviding
    private let action: ((String) -> Void)

    public init(action: @escaping ((String) -> Void)) {
        self.init(action: action, textProvider: QRScannerTextProvider())
    }

    public init(action: @escaping ((String) -> Void), textProvider: QRScannerTextProviding) {
        self.action = action
        self.textProvider = textProvider
        _model = State(initialValue: QRScanner(scannerState: .idle, imageState: .empty))
    }

    public var body: some View {
        VStack {
            switch model.scannerState {
            case .idle:
                ProgressView()
                    .progressViewStyle(.circular)
            case .scanning:
                QRScannerViewWrapper(scanResult: onHandleScanResult)
            case .failure(let error):
                ContentUnavailableView(
                    label: {
                        switch error {
                        case .notSupported:
                            Label(textProvider.errorNotSupportedTitle, systemImage: "xmark.circle.fill")
                        case .permissionsNotGranted:
                            Label(textProvider.errorPermissionsNotGrantedTitle, systemImage: "lock.fill")
                        case .decoding:
                            Label(textProvider.errorDecodingTitle, systemImage: "exclamationmark.triangle.fill")
                        case .unexpected:
                            Label(textProvider.errorUnexpectedTitle, systemImage: "exclamationmark.triangle.fill")
                        }
                    },
                    description: {
                        Text(error.localizedDescription(using: textProvider))
                    },
                    actions: {
                        switch error {
                        case .notSupported:
                            photosPicker {
                                Text(textProvider.selectFromPhotos)
                            }
                        case .permissionsNotGranted:
                            Button(textProvider.openSettings, action: onSelectOpenSettings)
                        case .decoding, .unexpected:
                            Button(textProvider.retry, action: onRefreshScanner)
                        }
                    }
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                photosPicker {
                    Image(systemName: "photo.artframe")
                        .bold()
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.down")
                        .bold()
                }
            }
        }
        .onChange(of: model.selectedPhoto, onLoadPhoto)
        .onChange(of: model.imageState, onChangeImageState)
        .task {
            onRefreshScanner()
        }
    }

    private func photosPicker<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        PhotosPicker(
            selection: $model.selectedPhoto,
            matching: .images,
            photoLibrary: .shared()
        ) {
            content()
        }
    }
}

// MARK: - Actions

extension QRScannerView {
    private func onRefreshScanner() {
        model.refreshScannerState()
    }

    private func onSelectOpenSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(settingsURL)
    }

    private func onLoadPhoto(_ oldValue: PhotosPickerItem?, _ newValue: PhotosPickerItem?) {
        guard let newValue else { return }
        Task {
            await model.process(photoItem: newValue)
        }
    }

    private func onChangeImageState(_ oldValue: ImageState, _ newValue: ImageState) {
        guard case .success(let uIImage) = newValue else { return }

        do {
            let code = try model.retriveQR(image: uIImage)
            onHandleScanResult(.success(code))
        } catch {
            model.refreshScannerState(error: error)
        }
    }

    private func onHandleScanResult(_ result: (Result<String, Error>)) {
        guard case .success(let code) = result else { return }
        action(code)
        dismiss()
    }
}
