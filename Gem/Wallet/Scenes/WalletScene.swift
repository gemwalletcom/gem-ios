// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import Settings
import Keystore
import Store
import GRDBQuery
import Style
import Localization

struct WalletScene: View {
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

    let pricesTimer = Timer.publish(every: 600, tolerance: 1, on: .main, in: .common).autoconnect()

    @Binding var isPresentingSelectType: SelectAssetType?

    let model: WalletSceneViewModel
//    @State private var selectAssetNavigationPath = NavigationPath()

    public init(
        model: WalletSceneViewModel,
        isPresentingSelectType: Binding<SelectAssetType?>
    ) {
        self.model = model
        _isPresentingSelectType = isPresentingSelectType

        try? model.setupWallet()

        _assets = Query(constant: model.assetsRequest)
        _assetsPinned = Query(constant: model.assetsPinnedRequest)
        _fiatValue = Query(constant: model.fiatValueRequest)
        _dbWallet = Query(constant: model.walletRequest)
        _banners = Query(constant: model.bannersRequest)
    }
    
    var body: some View {
        List {
           Section { } header: {
                WalletHeaderView(
                    model: WalletHeaderViewModel(
                        walletType: model.wallet.type,
                        value: fiatValue
                    )
                ) {
                    isPresentingSelectType = $0.selectType
                }
                .padding(.top, Spacing.small)
            }
            .frame(maxWidth: .infinity)
            .textCase(nil)
            .listRowSeparator(.hidden)
            .listRowInsets(.zero)

            Section {
                BannerView(
                    banners: banners,
                    action: onBannerAction,
                    closeAction: bannerService.onClose
                )
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
        }
        .refreshable {
            await refreshable()
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
        .onReceive(pricesTimer) { time in
            runUpdatePrices()
        }
    }
}

// MARK: - Actions

extension WalletScene {

    func refreshable() async {
        if let walletId = keystore.currentWalletId {
            Task {
                do {
                    try await model.fetch(walletId: walletId, assets: assets)
                } catch {
                    NSLog("refreshable error: \(error)")
                }
            }
        }
        
        runAddressStatusCheck()
    }

    func fetch() {
        Task {
            do {
                try await model.fetch(assets: assets)
            } catch {
                NSLog("fetch error: \(error)")
            }
        }
        
        runAddressStatusCheck()
    }
    
    func runAddressStatusCheck() {
        if let wallet = keystore.currentWallet {
            Task {
                await walletsService.runAddressStatusCheck(wallet)
            }
        }
    }

    private func runUpdatePrices() {
        NSLog("runUpdatePrices")
        Task {
            try await walletsService.updatePrices()
        }
    }
    
    private func onBannerAction(banner: Banner) {
        let action = BannerViewModel(banner: banner).action
        switch banner.event {
        case .stake,
            .enableNotifications,
            .accountActivation,
            .accountBlockedMultiSignature:
            Task {
                try await bannerService.handleAction(action)
            }
        }
    }
}

