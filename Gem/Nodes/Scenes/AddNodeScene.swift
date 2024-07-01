// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style

struct AddNodeScene: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject var model: AddNodeSceneViewModel
    @State private var isPresentingScanner: Bool = false
    @State private var isPresentingErrorAlert: String?

    @FocusState private var focusedField: Field?

    var onDismiss: (() -> Void)

    enum Field: Int, Hashable {
        case address
    }

    var body: some View {
        VStack {
            List {
                networkSection
                inputSection
                nodeInfoView
            }
            Spacer()
            StatefullButton(
                text: model.actionButtonTitle,
                viewState: model.state,
                action: onSelectImport
            )
            .disabled(model.shouldDisableImportButton)
            .frame(maxWidth: Spacing.scene.button.maxWidth)
        }
        .padding(.bottom, Spacing.scene.bottom)
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
        .sheet(isPresented: $isPresentingScanner) {
            ScanQRCodeNavigationStack(isPresenting: $isPresentingScanner, action: onScanFinished(_:))
        }
        .alert(item: $isPresentingErrorAlert) {
            Alert(title: Text(""), message: Text($0))
        }
    }
}

// MARK: - UI Components

extension AddNodeScene {
    
    private var networkSection: some View {
        Section(Localized.Transfer.network) {
            ChainView(chain: model.chain)
        }
    }
    
    private var inputSection: some View {
        Section {
            HStack {
                FloatTextField(model.inputFieldTitle, text: $model.inputFieldValue)
                    .textFieldStyle(.plain)
                    .focused($focusedField, equals: .address)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                    .onSubmit(onSubmitUrl)
                Spacer()
                HStack(spacing: Spacing.medium) {
                    ListButton(image: Image(systemName: SystemImage.paste), action: onSelectPaste)
                    ListButton(image: Image(systemName: SystemImage.qrCode), action: onSelectScan)
                }
            }
        } footer: {
            if case let .error(error) = model.state {
                ListItemErrorView(
                    errorTitle: model.errorTitle,
                    error: error,
                    retryTitle: model.errorRetryTitle,
                    retryAction: onSelectRetry
                )
            }
        }
    }

    @ViewBuilder
    private var nodeInfoView: some View {
        switch model.state {
        case .noData, .loading, .error:
            EmptyView()
        case let .loaded(result):
            Section {
                if let chainId = result.chainID {
                    ListItemView(
                        title: model.chainIdTitle,
                        subtitle: chainId
                    )
                }
                ListItemView(
                    title: model.inSyncTitle,
                    subtitle: result.isInSync ? "✅" : "❌"
                )
                ListItemView(
                    title: model.latestBlockTitle,
                    subtitle: result.blockNumber
                )
                ListItemView(
                    title: model.latencyTitle,
                    subtitle: result.latency.formattedValue
                )
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
        model.inputFieldValue = content.trim()
        fetch()
    }

    private func onSelectImport() {
        do {
            try model.importFoundNode()
            onDismiss()
        } catch {
            isPresentingErrorAlert = error.localizedDescription
        }
    }

    private func onScanFinished(_ result: String) {
        model.inputFieldValue = result
        fetch()
    }

    private func onSelectScan() {
        isPresentingScanner = true
    }

    private func onSelectRetry() {
        fetch()
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

#Preview {
    return NavigationStack {
        AddNodeScene(model: .init(chain: .ethereum, nodeService: .main)) { }
    }
}
