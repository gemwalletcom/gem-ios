// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import PrimitivesComponents
import Components
import Localization
import GRDBQuery
import Primitives
import Store

public struct WalletImageScene: View {
    enum Tab: Equatable {
        case emoji, collections
    }
    
    @State private var selectedTab: Tab = .emoji

    @State private var model: WalletImageViewModel
    
    @Query<NFTAssetsRequest>
    private var nftAssets: [NFTAsset]
    
    public init(model: WalletImageViewModel) {
        _model = State(initialValue: model)
        _nftAssets = Query(constant: model.nftAssetsRequest)
    }

    public var body: some View {
        VStack {
            headerView
                .padding(.bottom, Spacing.large)
            
            pickerView
                .padding(.bottom, Spacing.medium)
                .padding(.horizontal, Spacing.medium)
            
            listView
            
            Spacer()
        }
        .background(Colors.grayBackground)
    }
    
    private var headerView: some View {
        VStack {
            ZStack() {
                AvatarView(
                    walletId: model.wallet.id,
                    size: model.emojiViewSize
                )
                .padding(.vertical, Spacing.large)
                
                if model.isVisibleClearButton {
                    Button(action: {
                        withAnimation {
                            model.setDefaultAvatar()
                        }
                    }) {
                        Image(systemName: SystemImage.xmark)
                            .foregroundColor(Colors.black)
                            .padding(Spacing.small)
                            .background(Colors.grayVeryLight)
                            .clipShape(Circle())
                            .background(
                                Circle().stroke(Colors.white, lineWidth: Spacing.extraSmall)
                            )
                    }
                    .offset(x: model.offset, y: -model.offset)
                    .transition(.opacity)
                }
            }
        }
    }
    
    private var pickerView: some View {
        Picker("", selection: $selectedTab.animation()) {
            Text(Localized.Common.emoji).tag(Tab.emoji)
            Text(Localized.Nft.collections).tag(Tab.collections)
        }
        .pickerStyle(SegmentedPickerStyle())
    }
    
    @ViewBuilder
    private var listView: some View {
        ScrollView {
            LazyVGrid(
                columns: model.getColumns(for: selectedTab),
                alignment: .center,
                spacing: Spacing.medium
            ) {
                switch selectedTab {
                case .emoji:
                    emojiListView
                case .collections:
                    nftAssetListView
                }
            }
            .padding(.horizontal, Spacing.medium)
        }
        .highPriorityGesture(DragGesture())
    }
    
    private var emojiListView: some View {
        ForEach(model.emojiList, id: \.self) { value in
            EmojiButton(
                color: value.color,
                emoji: value.emoji,
                action: {
                    model.setAvatarImage(color: value.color.uiColor, text: value.emoji)
                }
            )
            .frame(maxWidth: .infinity)
            .transition(.opacity)
        }
    }
    
    private var nftAssetListView: some View {
        ForEach(model.buildNftAssetsItems(from: nftAssets), id: \.imageURL) { assetImage in
            let view = GridPosterView(assetImage: assetImage, title: nil)
            NavigationCustomLink(with: view) {
                onSelectNftAsset(url: assetImage.imageURL)
            }
        }
    }
}

// MARK: - Actions

extension WalletImageScene {
    func onSelectNftAsset(url: URL?) {
        Task {
            await model.setImage(from: url)
        }
    }
}
