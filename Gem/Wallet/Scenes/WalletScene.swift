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
import InfoSheet

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
    @Environment(\.observablePreferences) private var observablePreferences

    @Query<TotalValueRequest>
    private var totalFiatValue: Double

    @Query<AssetsRequest>
    private var assets: [AssetData]

    @Query<BannersRequest>
    private var banners: [Primitives.Banner]

    @Query<WalletRequest>
    var dbWallet: Wallet?

    let pricesTimer = Timer.publish(every: 600, tolerance: 1, on: .main, in: .common).autoconnect()

    @Binding var isPresentingSelectType: SelectAssetType?
    
    @State private var isPresentingInfoSheet: InfoSheetType? = .none
    
    let model: WalletSceneViewModel

    public init(
        model: WalletSceneViewModel,
        isPresentingSelectType: Binding<SelectAssetType?>
    ) {
        self.model = model
        _isPresentingSelectType = isPresentingSelectType

        try? model.setupWallet()

        _assets = Query(constant: model.assetsRequest)
        _totalFiatValue = Query(constant: model.totalFiatValueRequest)
        _dbWallet = Query(constant: model.walletRequest)
        _banners = Query(constant: model.bannersRequest)
    }
    
    private var sections: AssetsSections {
        AssetsSections.from(assets)
    }

    var body: some View {
        @Bindable var preferences = observablePreferences

        List {
           Section { } header: {
                WalletHeaderView(
                    model: WalletHeaderViewModel(
                        walletType: model.wallet.type,
                        value: totalFiatValue
                    ),
                    isHideBalanceEnalbed: $preferences.isHideBalanceEnabled,
                    onHeaderAction: onHeaderAction,
                    onInfoSheetAction: onInfoSheetAction
                )
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

            if !sections.pinned.isEmpty {
                Section {
                    WalletAssetsList(
                        assets: sections.pinned,
                        copyAssetAddress: { model.copyAssetAddress(for: $0) },
                        hideAsset: { try? model.hideAsset($0) },
                        pinAsset: { (assetId, value) in
                            try? model.pinAsset(assetId, value: value)
                        },
                        showBalancePrivacy: $preferences.isHideBalanceEnabled
                    )
                } header: {
                    HStack {
                        Images.System.pin
                        Text(Localized.Common.pinned)
                    }
                }
            }

            Section {
                WalletAssetsList(
                    assets: sections.assets,
                    copyAssetAddress: { address in
                        model.copyAssetAddress(for: address)
                    },
                    hideAsset: {
                        try? model.hideAsset($0)
                    },
                    pinAsset: { (assetId, value) in
                        try? model.pinAsset(assetId, value: value)
                    },
                    showBalancePrivacy: $preferences.isHideBalanceEnabled
                )
            } footer: {
                ListButton(
                    title: Localized.Wallet.manageTokenList,
                    image: Images.Actions.manage,
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
                    Images.Actions.manage
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $isPresentingInfoSheet) {
            InfoSheetScene(model: InfoSheetViewModel(type: $0))
        }
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
    
    private func onInfoSheetAction(type: InfoSheetType) {
        isPresentingInfoSheet = type
    }
    
    private func onHeaderAction(type: HeaderButtonType) {
        isPresentingSelectType = type.selectType
    }
}

