// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import PrimitivesComponents
import SwiftUI
import Style
import Primitives
import Components
import AvatarService

@MainActor
@Observable
public final class AvatarCustomizationViewModel {
    public let wallet: Wallet
    public let avatarViewModel: AvatarViewModel
    private let avatarService: AvatarService
    
    public var image: UIImage?
    
    public init(
        wallet: Wallet,
        avatarService: AvatarService
    ) {
        self.wallet = wallet
        self.avatarService = avatarService
        self.avatarViewModel = AvatarViewModel(
            wallet: wallet,
            allowEditing: true,
            onClear: {
                try? avatarService.remove(for: wallet.id)
            }
        )
    }
    
    let headerButtons: [HeaderButton] = [
        .init(type: .gallery, isEnabled: true),
        .init(type: .emoji, isEnabled: true),
        .init(type: .nft, isEnabled: true)
    ]
    
    var emojiColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 16), count: 5)
    }
    
    var emojiList: [EmojiValue] = {
        Array(Emoji.WalletAvatar.allCases.map { EmojiValue(emoji: $0.rawValue, color: .random()) }.prefix(10))
    }()
    
    // MARK: - Public methods
    
    public func setImage(from url: URL?) async {
        do {
            guard let url else {
                throw AnyError("Wrong nft asset url")
            }
            try await avatarService.save(url: url, walletId: wallet.id)
        } catch {
            print("Set nft image error:", error)
        }
    }
    
    public func setImage(_ image: UIImage?) {
        do {
            guard let image else { return }
            try avatarService.save(image: image, walletId: wallet.id)
        } catch {
            print("Set image error:", error)
        }
    }
}
