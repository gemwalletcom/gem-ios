// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Components
import Style
import Primitives
import Localization
import PrimitivesComponents
import GRDBQuery
import Store
import Onboarding

public struct WalletDetailScene: View {
    enum Field: Int, Hashable {
        case name
    }

    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    @State private var model: WalletDetailViewModel
    
    @Query<WalletRequest>
    var dbWallet: Wallet?

    public init(model: WalletDetailViewModel) {
        _model = State(initialValue: model)
        _dbWallet = Query(constant: model.walletRequest)
    }
    
    public var body: some View {
        VStack {
            List {
                Section {
                    FloatTextField(Localized.Wallet.name, text: $model.nameInput, allowClean: focusedField == .name)
                        .focused($focusedField, equals: .name)
                } header: {
                    HStack {
                        Spacer()
                        VStack(spacing: .medium) {
                            if let dbWallet {
                                AvatarView(
                                    avatarImage: model.avatarAssetImage(for: dbWallet),
                                    size: .image.extraLarge,
                                    action: model.onSelectImage
                                )
                                .padding(.bottom, .extraLarge)
                            }
                        }
                        Spacer()
                    }
                }
                switch model.wallet.type {
                case .multicoin, .single:
                    Section {
                        NavigationCustomLink(
                            with: ListItemView(title: Localized.Common.show(Localized.Common.secretPhrase)),
                            action: model.onShowSecretPhrase
                        )
                    } header: {
                        Text(Localized.Common.secretPhrase)
                    }
                case .privateKey:
                    Section {
                        NavigationCustomLink(
                            with: ListItemView(title: Localized.Common.show(Localized.Common.privateKey)),
                            action: model.onShowPrivateKey
                        )
                    } header: {
                        Text(Localized.Common.privateKey)
                    }
                case .view:
                    EmptyView()
                }
                Section {
                    switch model.address {
                    case .account(let account):
                        AddressListItemView(
                            model: AddressListItemViewModel(
                                title: Localized.Common.address,
                                account: account,
                                mode: .auto(addressStyle: .short),
                                addressLink: model.addressLink(account: account)
                            )
                        )
                    case .none:
                        EmptyView()
                    }
                }
                Section {
                    HStack {
                        Spacer()
                        Button(role: .destructive, action: model.onSelectDelete) {
                            Text(Localized.Common.delete)
                                .foregroundStyle(Colors.red)
                        }
                        Spacer()
                    }
                }
            }
        }
        .padding(.bottom, .scene.bottom)
        .background(Colors.grayBackground)
        .frame(maxWidth: .infinity)
        .onChange(of: model.nameInput, model.onChangeWalletName)
        .navigationTitle(model.title)
        .alert(
            Localized.Common.deleteConfirmation(model.name),
            presenting: $model.isPresentingDeleteConfirmation,
            sensoryFeedback: .warning,
            actions: { _ in
                Button(
                    Localized.Common.delete,
                    role: .destructive,
                    action: {
                        if model.onDelete() {
                            dismiss()
                        }
                    }
                )
            }
        )
        .alertSheet($model.isPresentingAlertMessage)
        .sheet(item: $model.isPresentingExportWallet) {
            ExportWalletNavigationStack(flow: $0)
        }
    }
}

