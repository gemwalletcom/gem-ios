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
            if let dbWallet {
                AvatarView(
                    avatarImage: WalletViewModel(wallet: dbWallet).avatarImage,
                    size: model.emojiViewSize,
                    action: setDefaultAvatar
                )
                .padding(.top, .medium)
                .padding(.bottom, .extraLarge)
            }
            switch model.source {
            case .onboarding:
                listView
            case .wallet:
                pickerView
                    .padding(.bottom, .medium)
                    .padding(.horizontal, .medium)
                listView
            }
        }
        .navigationTitle(model.title)
        .background(Colors.grayBackground)
    }
    
    private var pickerView: some View {
        Picker("", selection: $selectedTab) {
            Text(Localized.Common.emoji).tag(Tab.emoji)
            Text(Localized.Nft.collections).tag(Tab.collections)
        }
        .pickerStyle(.segmented)
    }
    
    @ViewBuilder
    private var listView: some View {
        ScrollView {
            LazyVGrid(
                columns: model.getColumns(for: selectedTab),
                alignment: .center,
                spacing: .medium
            ) {
                switch selectedTab {
                case .emoji:
                    emojiListView
                case .collections:
                    nftAssetListView
                }
            }
            .padding(.horizontal, .medium)
        }
        .overlay {
            if nftDataList.isEmpty, case .collections = selectedTab {
                EmptyContentView(model: model.emptyContentModel)
            }
        }
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

private extension WalletImageScene {
    func onSelectNftAsset(_ item: WalletImageViewModel.NFTAssetImageItem) {
        guard let url = item.assetImage.imageURL else {
            return
        }
        Task {
            await model.setImage(from: url)
        }
    }
    
    func setDefaultAvatar() {
        model.setDefaultAvatar()
    }
}
