// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import WalletService
import AvatarService
import PrimitivesComponents
import enum Keystore.KeystoreImportType

@Observable
@MainActor
public final class ImportWalletViewModel {

    let walletService: WalletService
    let avatarService: AvatarService
    let nameService: any NameServiceable
    let onComplete: VoidAction

    var isPresentingSelectImageWallet: Wallet?

    public init(
        walletService: WalletService,
        avatarService: AvatarService,
        nameService: any NameServiceable,
        onComplete: VoidAction
    ) {
        self.walletService = walletService
        self.avatarService = avatarService
        self.nameService = nameService
        self.onComplete = onComplete
    }

    public var isAcceptTermsCompleted: Bool {
        walletService.isAcceptTermsCompleted
    }
}

// MARK: - Actions

extension ImportWalletViewModel {
    func presentSelectImage(wallet: Wallet) {
        isPresentingSelectImageWallet = wallet
    }
}
