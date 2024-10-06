// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import PhotosUI

@MainActor
public struct QRScannerView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss

    @State private var model: QRScannerViewModel

    private let action: ((String) -> Void)

    public init(resources: QRScannerResources, action: @escaping ((String) -> Void)) {
        self.action = action
        _model = State(initialValue: QRScannerViewModel(scannerState: .idle, imageState: .empty, resources: resources))
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
                        if let localizedError = error as? LocalizedQRCodeError, let titleImage = localizedError.titleImage {
                            Label(titleImage.title, systemImage: titleImage.systemImage)
                        }
                    },
                    description: {
                        Text(error.localizedDescription)
                    },
                    actions: {
                        switch error {
                        case .notSupported:
                            let text = model.resources.selectFromPhotos
                            photosPicker {
                                Text(text)
                            }
                        case .permissionsNotGranted:
                            Button(model.resources.openSettings, action: onSelectOpenSettings)
                        case .decoding, .unknown:
                            Button(model.resources.tryAgain, action: onRefreshScanner)
                        }
                    }
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                let imageName = model.resources.gallerySystemImage
                photosPicker {
                    Image(systemName: imageName)
                        .bold()
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Text(model.resources.dismissText)
                }
            }
        }
        .onChange(of: model.selectedPhoto, onLoadPhoto)
        .onChange(of: model.imageState, onChangeImageState)
        .task {
            onRefreshScanner()
        }
    }

    private func photosPicker<Content: View>(@ViewBuilder content: @Sendable () -> Content) -> some View {
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
            let code = try model.retrieveQRCode(image: uIImage)
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
