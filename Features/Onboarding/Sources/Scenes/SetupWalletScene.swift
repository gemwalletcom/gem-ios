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
                FloatTextField(Localized.Wallet.walletName, text: $model.nameInput, allowClean: focusedField == .name)
                    .focused($focusedField, equals: .name)
            } header: {
                HStack {
                    Spacer()
                    AvatarView(
                        avatarImage: model.avatarAssetImage,
                        size: .image.extraLarge,
                        action: model.onSelectImage
                    )
                    .padding(.bottom, .extraLarge)
                    Spacer()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(Localized.Common.done, action: model.onComplete)
                    .bold()
            }
        }
        .listSectionSpacing(.compact)
        .safeAreaView {
            StateButton(
                text: Localized.Common.done,
                type: .primary(.normal),
                action: model.onComplete
            )
            .frame(maxWidth: Spacing.scene.button.maxWidth)
            .padding(.bottom, Spacing.scene.bottom)
        }
        .observeQuery(request: $model.walletRequest, value: $model.wallet)
        .onChange(of: model.nameInput, model.onChangeWalletName)
        .navigationTitle(model.title)
    }
}
