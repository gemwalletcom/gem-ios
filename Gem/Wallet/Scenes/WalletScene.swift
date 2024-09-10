// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import Settings
import Keystore
import Store
import GRDBQuery
import Style

struct WalletScene: View {
    
    @Environment(\.db) private var DB
    @Environment(\.keystore) private var keystore
    @Environment(\.assetsService) private var assetsService
    @Environment(\.transactionsService) private var transactionsService
    @Environment(\.connectionsService) private var connectionsService
    @Environment(\.walletsService) private var walletsService
    @Environment(\.isWalletsPresented) private var isWalletsPresented
    @Environment(\.nodeService) private var nodeService
    @Environment(\.bannerService) private var bannerService
    @Environment(\.stakeService) private var stakeService

    @Query<TotalValueRequest>
    private var fiatValue: Double

    @Query<AssetsRequest>
    private var assetsPinned: [AssetData]

    @Query<AssetsRequest>
    private var assets: [AssetData]

    @Query<BannersRequest>
    private var banners: [Primitives.Banner]

    @Query<WalletRequest>
    var dbWallet: Wallet?

    @State private var isPresentingSelectType: SelectAssetType? = nil
    
    let model: WalletSceneViewModel

    public init(
        model: WalletSceneViewModel
    ) {
        self.model = model

        try? model.setupWallet()

        _assets = Query(constant: model.assetsRequest, in: \.db.dbQueue)
        _assetsPinned = Query(constant: model.assetsPinnedRequest, in: \.db.dbQueue)
        _fiatValue = Query(constant: model.fiatValueRequest, in: \.db.dbQueue)
        _dbWallet = Query(constant: model.walletRequest, in: \.db.dbQueue)
        _banners = Query(constant: model.bannersRequest, in: \.db.dbQueue)
    }
    
    var body: some View {
        List {
           Section { } header: {
                WalletHeaderView(
                    model: WalletHeaderViewModel(walletType: model.wallet.type, value: fiatValue)
                ) {
                    isPresentingSelectType = $0.selectType
                }
                .padding(.top, Spacing.small)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .textCase(nil)
            .listRowSeparator(.hidden)
            .listRowInsets(.zero)

            Section {
                BannerView(banners: banners, action: onBannerAction, closeAction: onBannerClose)
            }

            if !assetsPinned.isEmpty {
                Section {
                    WalletAssetsList(
                        assets: assetsPinned,
                        copyAssetAddress: { model.copyAssetAddress(for: $0) },
                        hideAsset: { try? model.hideAsset($0) },
                        pinAsset: { (assetId, value) in
                            try? model.pinAsset(assetId, value: value)
                        }
                    )
                } header: {
                    HStack {
                        Image(systemName: SystemImage.pin)
                        Text(Localized.Common.pinned)
                    }
                }
            }

            Section {
                WalletAssetsList(
                    assets: assets,
                    copyAssetAddress: { address in
                        model.copyAssetAddress(for: address)
                    },
                    hideAsset: {
                        try? model.hideAsset($0)
                    },
                    pinAsset: { (assetId, value) in
                        try? model.pinAsset(assetId, value: value)
                    }
                )
            } footer: {
                ListButton(
                    title: Localized.Wallet.manageTokenList,
                    image: Image(.manageAssets),
                    action: {
                        isPresentingSelectType = .manage
                    }
                )
                .accessibilityIdentifier("manage")
                .padding(Spacing.medium)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .listSectionSpacing(.compact)
        }
        .refreshable {
            await refreshable()
        }
        .sheet(item: $isPresentingSelectType) { value in
            SelectAssetSceneNavigationStack(
                model: SelectAssetViewModel(
                    wallet: model.wallet,
                    keystore: keystore,
                    selectType: value,
                    assetsService: assetsService,
                    walletsService: walletsService
                )
            )
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                if let wallet = dbWallet {
                    HStack {
                        WalletBarView(
                            model: WalletBarViewViewModel.from(wallet: wallet, showChevron: true)
                        ) {
                            isWalletsPresented.wrappedValue.toggle()
                        }
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isPresentingSelectType = .manage
                } label: {
                    Image(.manageAssets)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: model.wallet, fetch)
        .taskOnce(fetch)
    }
    
    func refreshable() async {
        if let walletId = keystore.currentWalletId {
            Task {
                try await model.fetch(walletId: walletId, assets: assets)
            }
        }
    }

    func fetch() {
        Task {
            do {
                try await model.fetch(assets: assets)
            } catch {
                NSLog("fetch error: \(error)")
            }
        }
    }
}

// MARK: - Actions

extension WalletScene {

    private func onBannerAction(banner: Banner) {
        //
    }

    private func onBannerClose(banner: Banner) {
        Task { try bannerService.closeBanner(banner: banner) }
    }
}
