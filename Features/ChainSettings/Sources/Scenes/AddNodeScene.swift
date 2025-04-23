// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Localization
import Components
import QRScanner
import PrimitivesComponents

public struct AddNodeScene: View {
    @Environment(\.dismiss) private var dismiss

    @State private var model: AddNodeSceneViewModel
    @FocusState private var focusedField: Field?
    enum Field: Int, Hashable {
        case address
    }

    private let onDismiss: (() -> Void)?

    public init(model: AddNodeSceneViewModel, onDismiss: (() -> Void)? = nil) {
        _model = State(initialValue: model)
        self.onDismiss = onDismiss
    }

    public var body: some View {
        VStack {
            List {
                networkSection
                inputView
                nodeInfoView
            }
            Spacer()
            StateButton(
                text: model.actionButtonTitle,
                viewState: model.state,
                action: onSelectImport
            )
            .frame(maxWidth: .scene.button.maxWidth)
        }
        .onAppear {
            focusedField = .address
        }
        .padding(.bottom, .scene.bottom)
        .background(Colors.grayBackground)
        .frame(maxWidth: .infinity)
        .navigationTitle(model.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(model.doneButtonTitle, action: onSelectDone)
                    .bold()
            }
        }
        .sheet(isPresented: $model.isPresentingScanner) {
            ScanQRCodeNavigationStack(action: onHandleScan(_:))
        }
        .alert("",
            isPresented: $model.isPresentingErrorAlert.mappedToBool(),
            actions: {},
            message: {
                Text(model.isPresentingErrorAlert ?? "")
            }
        )
    }
}

// MARK: - UI Components

extension AddNodeScene {
    private var networkSection: some View {
        Section(Localized.Transfer.network) {
            ChainView(model: model.chainModel)
        }
    }

    @ViewBuilder
    private var inputView: some View {
        Section {
            FloatTextField(model.inputFieldTitle, text: $model.urlInput) {
                HStack(spacing: .medium) {
                    ListButton(image: Images.System.paste, action: onSelectPaste)
                    ListButton(image: Images.System.qrCode, action: onSelectScan)
                }
            }
            .focused($focusedField, equals: .address)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .submitLabel(.search)
            .onSubmit(onSubmitUrl)
        }
        if case let .error(error) = model.state {
            ListItemErrorView(errorTitle: model.errorTitle, error: error)
        }
    }

    @ViewBuilder
    private var nodeInfoView: some View {
        switch model.state {
        case .noData, .loading, .error:
            EmptyView()
        case let .data(result):
            Section {
                ListItemView(title: result.chainIdTitle, subtitle: result.chainIdValue)
                ListItemView(title: result.inSyncTitle, subtitle: result.inSyncValue)
                ListItemView(title: result.latestBlockTitle, subtitle: result.latestBlockValue)
                ListItemView(title: result.latencyTitle, subtitle: result.latecyValue)
            }
        }
    }
}

// MARK: - Actions

extension AddNodeScene {
    private func onSelectDone() {
        dismiss()
    }

    private func onSubmitUrl() {
        fetch()
    }

    private func onSelectPaste() {
        guard let content = UIPasteboard.general.string else {
            return
        }
        model.urlInput = content.trim()
        fetch()
    }

    private func onSelectImport() {
        do {
            try model.importFoundNode()
            onDismiss?()
        } catch {
            model.isPresentingErrorAlert = error.localizedDescription
        }
    }

    private func onHandleScan(_ result: String) {
        model.urlInput = result
        fetch()
    }

    private func onSelectScan() {
        model.isPresentingScanner = true
    }
}

// MARK: - Effects

extension AddNodeScene {
    private func fetch() {
        Task {
            await model.fetch()
        }
    }
}
