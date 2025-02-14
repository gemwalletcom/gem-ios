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
    public let avatarAssetImage: AssetImage
    private let avatarService: AvatarService
    private(set) var isVisibleClearButton: Bool
    
    public var image: UIImage?
    
    public init(
        wallet: Wallet,
        avatarService: AvatarService
    ) {
        self.wallet = wallet
        self.avatarService = avatarService
        self.avatarAssetImage = WalletViewModel(wallet: wallet).avatarImage
        self.isVisibleClearButton = wallet.imageUrl != nil
    }
    
    let headerButtons: [HeaderButton] = [
        .init(type: .gallery, isEnabled: true),
        .init(type: .emoji, isEnabled: true),
        .init(type: .nft, isEnabled: true)
    ]
    
    var emojiColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: Spacing.medium), count: 5)
    }
    
    var emojiList: [EmojiValue] = {
        Array(Emoji.WalletAvatar.allCases.map { EmojiValue(emoji: $0.rawValue, color: Colors.listStyleColor) }.prefix(10))
    }()
    
    // MARK: - Public methods
    
    public func setImage(from url: URL?) async {
        do {
            guard let url else { return }
            try await avatarService.save(url: url, walletId: wallet.id)
            isVisibleClearButton = true
        } catch {
            print("Set nft image error:", error)
        }
    }
    
    public func setImage(_ image: UIImage?) {
        do {
            guard let image else { return }
            try avatarService.save(image: image, walletId: wallet.id, targetWidth: Sizing.image.extraLarge)
            isVisibleClearButton = true
        } catch {
            print("Set image error:", error)
        }
    }
    
    public func setDefaultAvatar() {
        do {
            try avatarService.remove(for: wallet.id)
            isVisibleClearButton = false
        } catch {
            print("Setting default avatar error:", error)
        }
    }
}
