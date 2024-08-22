// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style

struct AddNodeScene: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject var model: AddNodeSceneViewModel

    var onDismiss: (() -> Void)

    @FocusState private var focusedField: Field?
    enum Field: Int, Hashable {
        case address
    }

    var body: some View {
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
        .sheet(isPresented: $model.isPresentingScanner) {
            ScanQRCodeNavigationStack(action: onHandleScan(_:))
        }
        .alert(item: $model.isPresentingErrorAlert) {
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
    
    @ViewBuilder
    private var inputView: some View {
        Section {
            HStack {
                FloatTextField(model.inputFieldTitle, text: $model.urlInput)
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
        if case let .error(error) = model.state {
            ListItemErrorView(errorTitle: model.errorTitle, error: error)
        }
    }

    @ViewBuilder
    private var nodeInfoView: some View {
        switch model.state {
        case .noData, .loading, .error:
            EmptyView()
        case let .loaded(result):
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
            onDismiss()
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

#Preview {
    return NavigationStack {
        AddNodeScene(model: .init(chain: .ethereum, nodeService: .main)) { }
    }
}
