// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import Components
import Primitives
import Localization

struct WalletListItemView: View {

    let model: WalletViewModel
    let currentWallet: Wallet?

    let onSelect: (@MainActor (Wallet) -> Void)
    let onEdit: (@MainActor (Wallet) -> Void)
    let onPin: (@MainActor (Wallet) -> Void)
    let onDelete: (@MainActor (Wallet) -> Void)

    init(
        wallet: Wallet,
        currentWallet: Wallet?,
        onSelect: @escaping (Wallet) -> Void,
        onEdit: @escaping (Wallet) -> Void,
        onPin: @escaping (Wallet) -> Void,
        onDelete: @escaping (Wallet) -> Void
    ) {
        self.currentWallet = currentWallet
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
                AssetImageView(assetImage: model.assetImage, size: Sizing.image.medium)
                ListItemView(title: model.name, titleExtra: model.subType)

                Spacer()

                if currentWallet == model.wallet {
                    SelectionImageView()
                }

                Button(
                    action: { onEdit(model.wallet) },
                    label: {
                        Image(systemName: SystemImage.settings)
                            .padding(.vertical, 8)
                            .padding(.leading, Spacing.small)
                    }
                )
                .buttonStyle(.borderless)
            }
        }
        .contextMenu {
            ContextMenuItem(
                title: Localized.Settings.title,
                image: SystemImage.settings
            ) {
                onEdit(model.wallet)
            }
            ContextMenuPin(isPinned: model.wallet.isPinned) {
                onPin(model.wallet)
            }
            ContextMenuDelete {
                onDelete(model.wallet)
            }
        }
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
