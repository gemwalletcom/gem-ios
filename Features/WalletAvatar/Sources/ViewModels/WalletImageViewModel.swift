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
public final class WalletImageViewModel {
    public let wallet: Wallet
    public let avatarAssetImage: AssetImage
    private let avatarService: AvatarService
    private(set) var isVisibleClearButton: Bool
    
    public init(
        wallet: Wallet,
        avatarService: AvatarService
    ) {
        self.wallet = wallet
        self.avatarService = avatarService
        self.avatarAssetImage = WalletViewModel(wallet: wallet).avatarImage
        self.isVisibleClearButton = wallet.imageUrl != nil
    }
    
    let emojiViewRenderSize = Sizing.image.extraLarge
    var offset: CGFloat { emojiViewRenderSize / (2 * sqrt(2)) }
    
    let headerButtons: [HeaderButton] = [
        .init(type: .emoji, isEnabled: true),
        .init(type: .nft, isEnabled: true)
    ]
    
    var emojiColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: Spacing.medium), count: 5)
    }
    
    var emojiList: [EmojiValue] = {
        Array(Emoji.WalletAvatar.allCases.map { EmojiValue(emoji: $0.rawValue, color: Colors.listStyleColor) }.prefix(20))
    }()
    
    public func emojiStyleViewModel() -> EmojiStyleViewModel {
        EmojiStyleViewModel { [weak self] value in
            self?.setAvatarImage(color: value.color.uiColor, text: value.emoji)
        }
    }
    
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
    
    public func setDefaultAvatar() {
        do {
            try avatarService.remove(for: wallet.id)
            isVisibleClearButton = false
        } catch {
            print("Setting default avatar error:", error)
        }
    }
    
    public func setAvatarImage(color: UIColor, text: String) {
        let renderer = UIGraphicsImageRenderer(
            size: CGSize(
                width: emojiViewRenderSize,
                height: emojiViewRenderSize
            )
        )
        
        let image = renderer.image { context in
            let rect = CGRect(x: 0, y: 0, width: emojiViewRenderSize, height: emojiViewRenderSize)

            let path = UIBezierPath(ovalIn: rect.insetBy(dx: -1, dy: -1))
            color.setFill()
            path.fill()
            
            let fontSize = emojiViewRenderSize * 0.7
            let font = UIFont.systemFont(ofSize: fontSize)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.white
            ]
            
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (emojiViewRenderSize - textSize.width) / 2,
                y: (emojiViewRenderSize - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )

            text.draw(in: textRect, withAttributes: attributes)
        }
        
        setImage(image)
    }
    
    // MARK: - Private methods
    
    private func setImage(_ image: UIImage?) {
        do {
            guard let image else { return }
            try avatarService.save(image: image, walletId: wallet.id)
            isVisibleClearButton = true
        } catch {
            print("Set image error:", error)
        }
    }
}
