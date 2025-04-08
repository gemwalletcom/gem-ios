// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Localization

public extension View {
    func contextMenu(_ items: [ContextMenuItemType]) -> some View {
        self.contextMenu {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                build(item)
            }
        }
    }

    func contextMenu(_ item: ContextMenuItemType) -> some View {
        contextMenu([item])
    }

    @ViewBuilder
    private func build(_ item: ContextMenuItemType) -> some View {
        switch item {
        case let .copy(title, value, onCopied):
            ContextMenuItem(
                title: title ?? Localized.Common.copy,
                systemImage: SystemImage.copy
            ) {
                UIPasteboard.general.string = value
                onCopied?(value)
            }
        case let .pin(isPinned, onPin):
            ContextMenuItem(
                title: isPinned ? Localized.Common.unpin : Localized.Common.pin,
                systemImage: isPinned ? SystemImage.unpin : SystemImage.pin,
                action: {
                    onPin?()
                }
            )
        case let .hide(onHide):
            ContextMenuItem(
                title: Localized.Common.hide,
                systemImage: SystemImage.hide,
                action: {
                    onHide?()
                }
            )
        case let .delete(onDelete):
            ContextMenuItem(
                title: Localized.Common.delete,
                systemImage: SystemImage.delete,
                role: .destructive,
                action: {
                    onDelete?()
                }
            )
        case let .url(title, url):
            ContextMenuItem(
                title: title,
                systemImage: SystemImage.globe
            ) {
                UIApplication.shared.open(url)
            }

        case let .custom(title, systemImage, role, action):
            ContextMenuItem(
                title: title,
                systemImage: systemImage,
                role: role
            ) {
                action?()
            }
        }
    }
}
