// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import PrimitivesComponents
import SwiftUI
import Style
import Primitives
import Components
import AvatarService
import Store
import Localization

@MainActor
@Observable
public final class WalletImageViewModel: Sendable {
    public let wallet: Wallet
    public let avatarAssetImage: AssetImage
    private let avatarService: AvatarService
    
    public init(
        wallet: Wallet,
        avatarService: AvatarService
    ) {
        self.wallet = wallet
        self.avatarService = avatarService
        self.avatarAssetImage = WalletViewModel(wallet: wallet).avatarImage
    }
    
    var title: String { Localized.Common.avatar }
    
    let emojiViewSize = Sizing.image.extraLarge
    
    var walletRequest: WalletRequest {
        WalletRequest(walletId: wallet.id)
    }
    
    var nftAssetsRequest: NFTAssetsRequest {
        NFTAssetsRequest(walletId: wallet.id)
    }
    
    let emojiList: [EmojiValue] = {
        Array(Emoji.WalletAvatar.allCases.map { EmojiValue(emoji: $0.rawValue, color: Colors.grayVeryLight) })
    }()
    
    func buildNftAssetsItems(from assets: [NFTAsset]) -> [(id: String, assetImage: AssetImage)] {
        assets.map {
            (
                id: $0.id,
                assetImage: AssetImage(
                    type: $0.name,
                    imageURL: $0.image.imageUrl.asURL,
                    placeholder: nil,
                    chainPlaceholder: nil
                )
            )
        }
    }
    
    func getColumns(for tab: WalletImageScene.Tab) -> [GridItem] {
        switch tab {
        case .emoji:
            Array(repeating: GridItem(.flexible(), spacing: Spacing.medium), count: 4)
        case .collections:
            Array(repeating: GridItem(spacing: Spacing.medium), count: 2)
        }
    }
    
    // MARK: - Public methods
    
    public func setImage(from url: URL?) async {
        do {
            guard let url else { return }
            try await avatarService.save(url: url, walletId: wallet.id)
        } catch {
            print("Set nft image error:", error)
        }
    }
    
    public func setDefaultAvatar() {
        do {
            try avatarService.remove(for: wallet.id)
        } catch {
            print("Setting default avatar error:", error)
        }
    }
    
    public func setAvatarImage(color: UIColor, text: String) {
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale

        let renderer = UIGraphicsImageRenderer(
            size: CGSize(width: emojiViewSize, height: emojiViewSize),
            format: format
        )

        let image = renderer.image { context in
            let rect = CGRect(x: 0, y: 0, width: emojiViewSize, height: emojiViewSize)

            let path = UIBezierPath(ovalIn: rect.insetBy(dx: -0.5, dy: -0.5))
            UIColor.clear.setFill()
            context.fill(rect)
            
            color.setFill()
            path.fill()

            let fontSize = emojiViewSize * 0.7
            let font = UIFont.boldSystemFont(ofSize: fontSize)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .paragraphStyle: paragraphStyle
            ]
            let attributedString = NSAttributedString(string: text, attributes: attributes)

            let textSize = attributedString.size()
            let textRect = CGRect(
                x: (emojiViewSize - textSize.width) / 2,
                y: (emojiViewSize - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )

            attributedString.draw(in: textRect)
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
        } catch {
            print("Set image error:", error)
        }
    }
}
