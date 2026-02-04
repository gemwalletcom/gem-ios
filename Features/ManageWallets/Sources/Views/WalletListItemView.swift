// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import Components
import Primitives
import Localization
import PrimitivesComponents

struct WalletListItemView: View {

    let model: WalletViewModel
    let currentWalletId: WalletId?

    let onSelect: ((Wallet) -> Void)
    let onEdit: ((Wallet) -> Void)
    let onPin: ((Wallet) -> Void)
    let onDelete: ((Wallet) -> Void)

    init(
        wallet: Wallet,
        currentWalletId: WalletId?,
        onSelect: @escaping (Wallet) -> Void,
        onEdit: @escaping (Wallet) -> Void,
        onPin: @escaping (Wallet) -> Void,
        onDelete: @escaping (Wallet) -> Void
    ) {
        self.currentWalletId = currentWalletId
        self.model = WalletViewModel(wallet: wallet)
        self.onSelect = onSelect
        self.onEdit = onEdit
        self.onPin = onPin
        self.onDelete = onDelete
    }

    var body: some View {
        // https://www.jessesquires.com/blog/2023/07/18/navigation-link-accessory-view-swiftui
        // Hack to hide chevron
        ZStack {
            NavigationCustomLink(
                with: EmptyView(),
                action: { onSelect(model.wallet) }
            )
            .opacity(0)

            HStack {
                ListItemView(
                    title: model.name,
                    titleExtra: model.subType,
                    imageStyle: .asset(assetImage: model.avatarImage)
                )

                Spacer()

                if currentWalletId == model.wallet.walletId {
                    SelectionImageView()
                }

                Button(
                    action: { onEdit(model.wallet) },
                    label: {
                        Images.System.settings
                            .padding(.vertical, .small)
                            .padding(.leading, .small)
                    }
                )
                .buttonStyle(.borderless)
            }
        }
        .contextMenu(
            [
                .custom(
                    title: Localized.Settings.title,
                    systemImage: SystemImage.settings,
                    action: { onEdit(model.wallet) }
                ),
                .pin(
                    isPinned: model.wallet.isPinned,
                    onPin: { onPin(model.wallet) }
                ),
                .delete( { onDelete(model.wallet) })
            ]
        )
        .swipeActions {
            Button(
                action: { onEdit(model.wallet) },
                label: {
                    Label("", systemImage: SystemImage.settings)
                }
            )
            .tint(Colors.gray)
            Button(
                Localized.Common.delete,
                action: { onDelete(model.wallet) }
            )
            .tint(Colors.red)
        }
    }
}
