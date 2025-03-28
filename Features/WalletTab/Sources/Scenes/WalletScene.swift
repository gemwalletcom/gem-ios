// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import Store
import GRDBQuery
import Style
import InfoSheet
import PrimitivesComponents

public struct WalletScene: View {
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
    @Binding var isPresentingWallets: Bool

    @State private var isPresentingInfoSheet: InfoSheetType? = .none

    let model: WalletSceneViewModel

    public init(
        model: WalletSceneViewModel,
        isPresentingSelectType: Binding<SelectAssetType?>,
        isPresentingWallets: Binding<Bool>
    ) {
        self.model = model
        _isPresentingSelectType = isPresentingSelectType
        _isPresentingWallets = isPresentingWallets

        try? model.setupWallet()

        _assets = Query(constant: model.assetsRequest)
        _totalFiatValue = Query(constant: model.totalFiatValueRequest)
        _banners = Query(constant: model.bannersRequest)
        _dbWallet = Query(constant: model.walletRequest)
    }

    private var sections: AssetsSections {
        AssetsSections.from(assets)
    }

    public var body: some View {
        @Bindable var preferences = model.observablePreferences

        List {
            Section { } header: {
                WalletHeaderView(
                    model: WalletHeaderViewModel(
                        walletType: model.wallet.type,
                        value: totalFiatValue,
                        currencyCode: preferences.preferences.currency
                    ),
                    isHideBalanceEnalbed: $preferences.isHideBalanceEnabled,
                    onHeaderAction: onHeaderAction,
                    onInfoAction: onSelectWalletHeaderInfo
                )
                .padding(.top, .small)
            }
           .cleanListRow()

            Section {
                BannerView(
                    banners: banners,
                    action: onBannerAction,
                    closeAction: model.closeBanner(banner:)
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
                        currencyCode: preferences.preferences.currency,
                        showBalancePrivacy: $preferences.isHideBalanceEnabled
                    )
                    .listRowInsets(.assetListRowInsets)
                } header: {
                    HStack {
                        model.pinImage
                        Text(model.pinnedTitle)
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
                    currencyCode: preferences.preferences.currency,
                    showBalancePrivacy: $preferences.isHideBalanceEnabled
                )
                .listRowInsets(.assetListRowInsets)
            } footer: {
                ListButton(
                    title: model.manageTokenTitle,
                    image: model.manageImage,
                    action: {
                        isPresentingSelectType = .manage
                    }
                )
                .accessibilityIdentifier("manage")
                .padding(.medium)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .refreshable {
            await refreshable()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                if let dbWallet {
                    WalletBarView(model: .from(wallet: dbWallet)) {
                        isPresentingWallets.toggle()
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isPresentingSelectType = .manage
                } label: {
                    model.manageImage
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $isPresentingInfoSheet) {
            InfoSheetScene(model: InfoSheetViewModel(type: $0))
        }
        .onChange(
            of: model.wallet,
            initial: false,
            fetch
        )
        .taskOnce {
            fetch()
        }
        .onReceive(pricesTimer) { time in
            runUpdatePrices()
        }
    }
}

// MARK: - Actions

extension WalletScene {

    func refreshable() async {
        fetch()
    }

    func fetch() {
        guard let dbWallet else { return }
        Task {
            do {
                try await model.fetch(wallet: dbWallet, assets: assets)
            } catch {
                NSLog("fetch error: \(error)")
            }
        }
        runAddressStatusCheck(wallet: dbWallet)
    }

    func runAddressStatusCheck(wallet: Wallet) {
        Task {
            await model.runAddressStatusCheck(wallet: wallet)
        }
    }

    private func runUpdatePrices() {
        Task {
            try await model.updatePrices()
        }
    }

    private func onBannerAction(banner: Banner) {
        let action = BannerViewModel(banner: banner).action
        switch banner.event {
        case .stake,
                .enableNotifications,
                .accountActivation,
                .accountBlockedMultiSignature,
                .activateAsset:
            Task {
                try await model.handleBanner(action: action)
            }
        }
    }

    private func onSelectWalletHeaderInfo() {
        isPresentingInfoSheet = .watchWallet
    }

    private func onHeaderAction(type: HeaderButtonType) {
        let selectType: SelectAssetType = switch type {
        case .buy: .buy
        case .send: .send
        case .receive: .receive(.asset)
        case .swap, .more, .stake:
            fatalError()
        }
        isPresentingSelectType = selectType
    }
}

// MARK: - Models extensions

extension WalletBarViewViewModel {
    static func from(wallet: Wallet) -> WalletBarViewViewModel {
        let model = WalletViewModel(wallet: wallet)
        return WalletBarViewViewModel(
            name: model.name,
            image: model.avatarImage
        )
    }
}
