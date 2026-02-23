// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components
import Primitives
import PrimitivesComponents
import Localization
import Store

public struct SetupWalletScene: View {
    enum Field: Int, Hashable {
        case name
    }

    @FocusState private var focusedField: Field?
    @State private var model: SetupWalletViewModel

    public init(model: SetupWalletViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        List {
            Section {
                FloatTextField(Localized.Wallet.name, text: $model.nameInput, allowClean: focusedField == .name)
                    .focused($focusedField, equals: .name)
            } header: {
                HStack {
                    Spacer()
                    AvatarView(
                        avatarImage: model.avatarAssetImage,
                        size: .image.extraLarge,
                        action: onSelectImage
                    )
                    .padding(.bottom, .extraLarge)
                    Spacer()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("", systemImage: SystemImage.xmark, action: model.onComplete)
            }
        }
        .listSectionSpacing(.compact)
        .safeAreaButton {
            StateButton(
                text: Localized.Common.done,
                type: .primary(.normal),
                action: model.onComplete
            )
        }
        .bindQuery(model.query)
        .onChange(of: model.nameInput, model.onChangeWalletName)
        .navigationTitle(model.title)
    }
}

// MARK: - Actions

extension SetupWalletScene {
    private func onSelectImage() {
        focusedField = nil
        model.onSelectImage()
    }
}
