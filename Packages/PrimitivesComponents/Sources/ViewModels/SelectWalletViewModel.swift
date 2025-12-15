// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import Components
import Style

public struct SelectWalletViewModel: SelectableListAdoptable {
    public typealias Item = Wallet

    public var title: String { Localized.Wallets.title }
    public var state: StateViewType<SelectableListType<Wallet>>
    public var selectedItems: Set<Wallet>
    public var selectionType: SelectionType = .checkmark

    public init(
        wallets: [Wallet],
        selectedWallet: Wallet
    ) {
        let sections: [ListSection<Wallet>] = [
            (Localized.Common.pinned, Images.System.pin, wallets.filter { $0.isPinned }),
            (nil, nil, wallets.filter { !$0.isPinned })
        ]
            .filter { $0.2.isNotEmpty }
            .map { title, image, items in
                ListSection(id: items.ids.joined(), title: title, image: image, values: items)
            }
        
        self.init(
            state: .data(.section(sections)),
            selectedItems: [selectedWallet],
            selectionType: .checkmark
        )
    }

    public init(
        state: StateViewType<SelectableListType<Wallet>>,
        selectedItems: [Wallet],
        selectionType: SelectionType
    ) {
        self.state = state
        self.selectedItems = Set(selectedItems)
    }
}

extension SelectWalletViewModel: SelectableListNavigationAdoptable {
    public var doneTitle: String { Localized.Common.done }
}

extension Wallet: @retroactive SimpleListItemViewable {
    public var title: String {
        name
    }

    public var assetImage: Components.AssetImage {
        WalletViewModel(wallet: self).avatarImage
    }
}
