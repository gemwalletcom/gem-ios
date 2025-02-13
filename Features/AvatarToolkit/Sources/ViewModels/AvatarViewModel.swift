// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import PrimitivesComponents
import Primitives
import Store
import Components
import SwiftUICore

@Observable
public final class AvatarViewModel {
    let wallet: Wallet
    let allowEditing: Bool
    let avatarRequest: AvatarRequest
    let defaultAvatar: AssetImage
    let onClear: VoidAction
    
    public init(
        wallet: Wallet,
        allowEditing: Bool,
        onClear: VoidAction = nil
    ) {
        self.wallet = wallet
        self.allowEditing = allowEditing
        self.avatarRequest = AvatarRequest(walletId: wallet.id)
        self.onClear = onClear
        self.defaultAvatar = AssetImage(
            type: .empty,
            imageURL: nil,
            placeholder: WalletViewModel(wallet: wallet).image,
            chainPlaceholder: WalletViewModel(wallet: wallet).subImage
        )
    }
    
    var avatarAssetImage: AssetImage?
    
    var clearButtonIsVisible: Bool {
        avatarAssetImage != nil
    }
    
    func setAvatar(_ avatar: AvatarValue?) {
        guard let avatar else {
            avatarAssetImage = nil
            return
        }
        avatarAssetImage = AssetImage(
            type: .empty,
            imageURL: avatar.url,
            placeholder: nil,
            chainPlaceholder: WalletViewModel(wallet: wallet).subImage
        )
    }
    
    func onChangeAvatar(oldValue: AvatarValue?, newValue: AvatarValue?) {
        setAvatar(newValue)
    }
}
