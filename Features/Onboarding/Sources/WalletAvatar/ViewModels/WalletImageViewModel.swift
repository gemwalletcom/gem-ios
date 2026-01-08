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

    public enum Source {
        case onboarding
        case wallet
    }

    struct NFTAssetImageItem: Identifiable, Sendable {
        let id: String
        let assetImage: AssetImage
    }

    public let wallet: Wallet
    public let source: Source
    private let avatarService: AvatarService

    let emojiViewSize: Sizing = .image.extraLarge
    let emojiList: [EmojiValue] = {
        Array(Emoji.WalletAvatar.allCases.map { EmojiValue(emoji: $0.rawValue, color: Colors.grayVeryLight) })
    }()

    public init(
        wallet: Wallet,
        source: Source = .wallet,
        avatarService: AvatarService
    ) {
        self.wallet = wallet
        self.source = source
        self.avatarService = avatarService
    }

    var title: String {
        switch source {
        case .onboarding: Localized.Wallet.New.title
        case .wallet: Localized.Common.avatar
        }
    }

    var walletRequest: WalletRequest {
        WalletRequest(walletId: wallet.walletId)
    }

    var nftAssetsRequest: NFTRequest {
        NFTRequest(walletId: wallet.walletId, filter: .all)
    }

    var emptyContentModel: EmptyContentTypeViewModel {
        EmptyContentTypeViewModel(type: .nfts(action: nil))
    }

    func buildNftAssetsItems(from list: [NFTData]) -> [NFTAssetImageItem] {
        list
            .map { $0.assets }
            .reduce([], +)
            .map {
                NFTAssetImageItem(
                    id: $0.id,
                    assetImage: AssetImage(
                        type: $0.name,
                        imageURL: $0.images.preview.url.asURL,
                        placeholder: nil,
                        chainPlaceholder: nil
                    )
                )
            }
    }
    
    func getColumns(for tab: WalletImageScene.Tab) -> [GridItem] {
        switch tab {
        case .emoji:
            Array(repeating: GridItem(.flexible(), spacing: .medium), count: 4)
        case .collections:
            Array(repeating: GridItem(spacing: .medium), count: 2)
        }
    }
    
    // MARK: - Public methods
    
    public func setImage(from url: URL) async {
        do {
            try await avatarService.save(url: url, for: wallet)
        } catch {
            debugLog("Set nft image error: \(error)")
        }
    }
    
    public func setDefaultAvatar() {
        do {
            try avatarService.remove(for: wallet)
        } catch {
            debugLog("Setting default avatar error: \(error)")
        }
    }
    
    public func setAvatarEmoji(value: EmojiValue) {
        if let image = drawImage(color: value.color.uiColor, text: value.emoji) {
            setImage(image)
        }
    }
    
    // MARK: - Private methods
    
    private func drawImage(color: UIColor, text: String) -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale

        let renderer = UIGraphicsImageRenderer(
            size: CGSize(width: emojiViewSize, height: emojiViewSize),
            format: format
        )

        return renderer.image { context in
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
    }
    
    private func setImage(_ image: UIImage) {
        do {
            guard let data = image.compress() else {
                throw AnyError("Compression image failed")
            }
            try avatarService.save(data: data, for: wallet)
        } catch {
            debugLog("Set image error: \(error)")
        }
    }
}
