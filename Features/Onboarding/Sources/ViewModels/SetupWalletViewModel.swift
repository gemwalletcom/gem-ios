// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesComponents
import Components
import Localization
import Store
import Style
import WalletService

@MainActor
@Observable
public final class SetupWalletViewModel: Sendable {

    private let walletService: WalletService
    private let onSelectImageAction: (Wallet) -> Void
    private let onCompleteAction: (Wallet) -> Void

    var wallet: Wallet?
    var nameInput: String
    var walletRequest: WalletRequest

    public init(
        wallet: Wallet,
        walletService: WalletService,
        onSelectImage: @escaping (Wallet) -> Void,
        onComplete: @escaping (Wallet) -> Void
    ) {
        self.wallet = wallet
        self.walletService = walletService
        self.nameInput = wallet.name
        self.walletRequest = WalletRequest(walletId: wallet.id)
        self.onSelectImageAction = onSelectImage
        self.onCompleteAction = onComplete
    }

    var title: String {
        switch wallet?.source {
        case .create: Localized.Wallet.New.title
        case .import, .none: Localized.Common.wallet
        }
    }

    var avatarAssetImage: AssetImage {
        guard let wallet else { return AssetImage(placeholder: Images.Logo.logo) }
        let avatar = WalletViewModel(wallet: wallet).avatarImage
        return AssetImage(
            type: avatar.type,
            imageURL: avatar.imageURL,
            placeholder: avatar.placeholder,
            chainPlaceholder: Images.Wallets.editFilled
        )
    }

    func onSelectImage() {
        guard let wallet else { return }
        onSelectImageAction(wallet)
    }

    func onComplete() {
        guard let wallet else { return }
        onCompleteAction(wallet)
    }

    func onChangeWalletName() {
        do {
            guard let wallet else { return }
            try walletService.rename(walletId: wallet.walletId, newName: nameInput)
        } catch {
            debugLog("Rename wallet error: \(error)")
        }
    }
}
