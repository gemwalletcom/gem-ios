// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import Components
import Store
import Style
import Localization
import PriceAlertService
import StakeService
import PrimitivesComponents
import Preferences
import ExplorerService

class AssetSceneViewModel: ObservableObject {
    private let walletsService: WalletsService
    private let assetsService: AssetsService
    private let transactionsService: TransactionsService
    private let priceAlertService: PriceAlertService

    let assetModel: AssetViewModel
    let assetDataModel: AssetDataViewModel
    let walletModel: WalletViewModel
    let explorerService: ExplorerService = .standart

    private let preferences: SecurePreferences = .standard
    private let transactionsLimit = 50

    init(
        walletsService: WalletsService,
        assetsService: AssetsService,
        transactionsService: TransactionsService,
        priceAlertService: PriceAlertService,
        assetDataModel: AssetDataViewModel,
        walletModel: WalletViewModel
    ) {
        self.walletsService = walletsService
        self.assetsService = assetsService
        self.transactionsService = transactionsService
        self.priceAlertService = priceAlertService

        self.assetModel = AssetViewModel(asset: assetDataModel.asset)
        self.assetDataModel = assetDataModel
        self.walletModel = walletModel
    }

    var title: String { assetModel.name }
    
    var viewAddressOnTitle: String { Localized.Asset.viewAddressOn(addressLink.name) }
    var addressExplorerUrl: URL { addressLink.url }
    var tokenExplorerUrl: URL? { tokenLink?.url }

    var viewTokenOnTitle: String? {
        if let link = tokenLink {
            return Localized.Asset.viewTokenOn(link.name)
        }
        return .none
    }

    var showPriceView: Bool {
        !priceView.text.isEmpty && !priceChangeView.text.isEmpty
    }
    
    var showNetwork: Bool { true }
    var openNetwork: Bool { assetDataModel.asset.type != .native }
    var showBalances: Bool { assetDataModel.showBalances }
    var showStakedBalance: Bool { assetDataModel.isStakeEnabled }
    var showReservedBalance: Bool { assetDataModel.hasReservedBalance }

    var reservedBalanceUrl: URL? {
        assetModel.asset.chain.accountActivationFeeUrl
    }
    
    var networkField: String { Localized.Transfer.network }

    var networkText: String {
        if assetModel.asset.type == .native {
            return assetModel.asset.chain.asset.name
        }
        return "\(assetModel.asset.chain.asset.name) (\(assetModel.asset.type.rawValue))"
    }
    
    var networkAssetImage: AssetImage {
        AssetIdViewModel(assetId: assetModel.asset.chain.assetId).networkAssetImage
    }
    
    var priceView: TextValue {
        TextValue(
            text: assetDataModel.priceAmountText,
            style: .calloutSecondary)
    }
    
    var priceChangeView: TextValue {
        TextValue(
            text: assetDataModel.priceChangeText,
            style: TextStyle(
                font: .callout,
                color: assetDataModel.priceChangeTextColor,
                background: assetDataModel.priceViewModel.priceChangeTextBackgroundColor
            )
        )
    }
    
    var stakeAprText: String {
        guard let apr = assetDataModel.stakeApr else { return .empty }
        return Localized.Stake.apr(CurrencyFormatter(type: .percentSignLess).string(apr))
    }
    
    // locally comouted banners
    var banners: [Primitives.Banner] {
        if !assetDataModel.isActive {
            return [
                Primitives
                    .Banner(
                        wallet: .none,
                        asset: assetDataModel.asset,
                        chain: .none,
                        event: .activateAsset,
                        state: .alwaysActive
                    ),
            ]
        }
        return []
    }
}

// MARK: - Business Logic

extension AssetSceneViewModel {
    func updateAsset() async {
        do {
            try await assetsService.updateAsset(assetId: assetModel.asset.id)
        } catch {
            // TODO: - handle updateAsset error
            print("asset scene: updateAsset error \(error)")
        }
    }

    func updateWallet() async {
        do {
            async let updateAsset: () = try walletsService.updateAsset(
                walletId: walletModel.wallet.walletId,
                assetId: assetModel.asset.id
            )
            async let updateTransactions: () = try fetchTransactions()
            let _ = try await [updateAsset, updateTransactions]
        } catch {
            // TODO: - handle fetch error
            print("asset scene: updateWallet error \(error)")
        }
    }

    func enablePriceAlert() async {
        do {
            try await priceAlertService.addPriceAlert(for: assetModel.asset.id)
            try await priceAlertService.requestPermissions()
            try await priceAlertService.enablePriceAlerts()
        } catch {
            NSLog("enablePriceAlert error \(error)")
        }
    }

    func disablePriceAlert() async {
        do {
            try await priceAlertService.deletePriceAlert(assetIds: [assetModel.asset.id.identifier])
        } catch {
            NSLog("disablePriceAlert error \(error)")
        }
    }
}

// MARK: - Private

extension AssetSceneViewModel {
    private var tokenLink: BlockExplorerLink? {
        guard let tokenId = assetModel.asset.tokenId else {
            return .none
        }
        return explorerService.tokenUrl(chain: assetModel.asset.chain, address: tokenId)
    }

    private var addressLink: BlockExplorerLink {
        explorerService.addressUrl(chain: assetModel.asset.chain, address: assetDataModel.address)
    }

    private func fetchTransactions() async throws {
        do {
            guard let deviceId = try preferences.get(key: .deviceId) else {
                throw AnyError("deviceId is null")
            }
            try await transactionsService.updateForAsset(deviceId: deviceId, wallet: walletModel.wallet, assetId: assetModel.asset.id)
        } catch {
            // TODO: - handle fetchTransactions error
            print("asset scene: fetchTransactions error \(error)")
        }
    }
}
