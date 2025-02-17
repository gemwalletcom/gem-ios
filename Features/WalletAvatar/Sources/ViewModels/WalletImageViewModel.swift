// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import PrimitivesComponents
import SwiftUI
import Style
import Primitives
import Components
import AvatarService
import Store

@MainActor
@Observable
public final class WalletImageViewModel: Sendable {
    public private(set) var wallet: Wallet
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
    
    let emojiViewSize = Sizing.image.extraLarge
    var offset: CGFloat { emojiViewSize / (2 * sqrt(2)) }
    
    var nftAssetsRequest: NFTAssetsRequest {
        NFTAssetsRequest()
    }
    
    var emojiList: [EmojiValue] = {
        Array(Emoji.WalletAvatar.allCases.map { EmojiValue(emoji: $0.rawValue, color: Colors.listStyleColor) })
    }()
    
    func buildNftAssetsItems(from assets: [NFTAsset]) -> [AssetImage] {
        assets.map {
            AssetImage(
                type: $0.name,
                imageURL: $0.image.imageUrl.asURL,
                placeholder: nil,
                chainPlaceholder: nil
            )
        }
    }
    
    func getColumns(for tab: WalletImageScene.Tab) -> [GridItem] {
        switch tab {
        case .emoji:
            Array(repeating: GridItem(.flexible(), spacing: Spacing.medium), count: 5)
        case .collections:
            Array(repeating: GridItem(spacing: Spacing.medium), count: 2)
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
                width: emojiViewSize,
                height: emojiViewSize
            )
        )
        
        let image = renderer.image { context in
            let rect = CGRect(x: 0, y: 0, width: emojiViewSize, height: emojiViewSize)

            let path = UIBezierPath(ovalIn: rect.insetBy(dx: -1, dy: -1))
            color.setFill()
            path.fill()
            
            let fontSize = emojiViewSize * 0.7
            let font = UIFont.systemFont(ofSize: fontSize)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.white
            ]
            
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (emojiViewSize - textSize.width) / 2,
                y: (emojiViewSize - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )

            text.draw(in: textRect, withAttributes: attributes)
        }
        
        setImage(image)
    }
    
    public func emojiStyleViewModel() -> EmojiStyleViewModel {
        EmojiStyleViewModel { [weak self] value in
            self?.setAvatarImage(color: value.color.uiColor, text: value.emoji)
        }
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
