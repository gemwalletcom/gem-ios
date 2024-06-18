// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style

struct ImportNodeScene: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject var model: ImportNodeSceneViewModel
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
                inputSection
                nodeInfoView
            }
            Spacer()
            StatefullButton(
                text: Localized.Wallet.Import.action,
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
                Button(Localized.Common.done, action: onSelectDone)
                    .bold()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: onSelectScan) {
                    Image(systemName: SystemImage.qrCode)
                }
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

extension ImportNodeScene {
    private var inputSection: some View {
        Section {
            HStack {
                FloatTextField(Localized.Nodes.ImportNode.rpcAddress, text: $model.urlString)
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
        }
    }

    @ViewBuilder
    private var nodeInfoView: some View {
        switch model.state {
        case .noData, .loading:
            EmptyView()
        case let .loaded(result):
            Section {
                ListItemView(
                    title: Localized.Nodes.ImportNode.chainId,
                    titleStyle: .body,
                    subtitle: result.chainID,
                    subtitleStyle: .calloutSecondary
                )
                ListItemView(
                    title: Localized.Nodes.ImportNode.inSync,
                    titleStyle: .body,
                    subtitle: result.isInSync ? "✅" : "❌",
                    subtitleStyle: .calloutSecondary
                )
                ListItemView(
                    title: Localized.Nodes.ImportNode.latestBlock,
                    titleStyle: .body,
                    subtitle: result.blockNumber,
                    subtitleStyle: .calloutSecondary
                )
            }
        case .error(let error):
            Section {
                StateErrorView(error: error, message: error.localizedDescription)
            }
        }
    }
}

// MARK: - Actions

extension ImportNodeScene {
    private func onSelectDone() {
        dismiss()
    }

    private func onSubmitUrl() {
        getNetwrokInfoAsync()
    }

    private func onSelectPaste() {
        guard let content = UIPasteboard.general.string else {
            return
        }
        model.urlString = content.trim()
        getNetwrokInfoAsync()
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
        model.urlString = result
        getNetwrokInfoAsync()
    }

    private func onSelectScan() {
        isPresentingScanner = true
    }
}

// MARK: - Logic

extension ImportNodeScene {
    private func getNetwrokInfoAsync() {
        Task {
            try await model.getNetworkInfo()
        }
    }
}

#Preview {
    return NavigationStack {
        ImportNodeScene(model: .init(chain: .ethereum, nodeService: .main)) { }
    }
}
