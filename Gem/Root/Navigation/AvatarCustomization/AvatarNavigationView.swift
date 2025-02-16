// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import WalletAvatar
import Primitives
import PrimitivesComponents
import Components
import NFT
import Localization
import ImageGalleryService

struct AvatarNavigationView: View {
    @Environment(\.nftService) private var nftService
    @Environment(\.deviceService) private var deviceService
    @Environment(\.avatarService) private var avatarService

    @State private(set) var model: WalletImageViewModel
    
    @State private var isPresentingCollectionScene = false
    @State private var isPresentingEmojiScene = false
    
    var body: some View {
        WalletImageScene(
            model: model,
            onHeaderAction: {
                onHeaderAction(type: $0)
            }
        )
        .sheet(isPresented: $isPresentingCollectionScene) {
            CollectionsNavigationStack(
                model: NFTCollectionViewModel(
                    wallet: model.wallet,
                    sceneStep: .collections,
                    nftService: nftService,
                    deviceService: deviceService,
                    avatarService: avatarService,
                    onSelect: { asset in
                        Task { @MainActor in
                            isPresentingCollectionScene = false
                            setImage(for: asset)
                        }
                    }
                ),
                navigationPath: .constant(NavigationPath())
            )
        }
        .sheet(isPresented: $isPresentingEmojiScene) {
            EmojiStyleScene(model: model.emojiStyleViewModel())
        }
    }
    
    private func onHeaderAction(type: HeaderButtonType) {
        switch type {
        case .nft:
            isPresentingCollectionScene = true
        case .emoji:
            isPresentingEmojiScene = true
        case .send, .receive, .buy, .swap, .stake, .more, .avatar, .gallery:
            fatalError()
        }
    }
    
    private func setImage(for asset: NFTAsset?) {
        Task {
            await model.setImage(from: URL(string: asset?.image.previewImageUrl ?? ""))
        }
    }
}
