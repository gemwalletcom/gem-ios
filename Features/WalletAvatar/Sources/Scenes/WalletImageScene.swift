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
    
    @Query<WalletRequest>
    var dbWallet: Wallet?
    
    @Query<NFTRequest>
    private var nftDataList: [NFTData]
    
    public init(model: WalletImageViewModel) {
        _model = State(initialValue: model)
        _nftDataList = Query(constant: model.nftAssetsRequest)
        _dbWallet = Query(constant: model.walletRequest)
    }

    public var body: some View {
        VStack {
            avatar
                .padding(.top, Spacing.medium)
                .padding(.bottom, Spacing.extraLarge)
            
            pickerView
                .padding(.bottom, Spacing.medium)
                .padding(.horizontal, Spacing.medium)
            
            listView
        }
        .navigationTitle(model.title)
        .background(Colors.grayBackground)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(Localized.Filter.clear) {
                    model.setDefaultAvatar()
                }
                .bold()
                .disabled(dbWallet?.imageUrl == nil)
            }
        }
    }
    
    private var avatar: some View {
        VStack {
            if let dbWallet {
                AssetImageView(
                    assetImage: WalletViewModel(wallet: dbWallet).avatarImage,
                    size: model.emojiViewSize,
                    overlayImageSize: Sizing.image.medium
                )
                .id(dbWallet.imageUrl)
            }
        }
        .animation(.default, value: dbWallet?.imageUrl)
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
        .overlay(content: {
            if nftDataList.isEmpty, case .collections = selectedTab {
                Text(Localized.Activity.EmptyState.message)
                    .textStyle(.body)
            }
        })
    }
    
    private var emojiListView: some View {
        ForEach(model.emojiList) { value in
            NavigationCustomLink(
                with: EmojiView(color: value.color, emoji: value.emoji)
            ) {
                model.setAvatarEmoji(value: value)
            }
            .frame(maxWidth: .infinity)
            .transition(.opacity)
        }
    }
    
    private var nftAssetListView: some View {
        ForEach(model.buildNftAssetsItems(from: nftDataList)) { item in
            let view = GridPosterView(assetImage: item.assetImage, title: nil)
            NavigationCustomLink(with: view) {
                onSelectNftAsset(item)
            }
        }
    }
}

// MARK: - Actions

extension WalletImageScene {
    func onSelectNftAsset(_ item: WalletImageViewModel.NFTAssetImageItem) {
        guard let url = item.assetImage.imageURL else {
            return
        }
        Task {
            await model.setImage(from: url)
        }
    }
}
