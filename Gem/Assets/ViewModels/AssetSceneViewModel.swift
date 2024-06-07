import Foundation
import Primitives
import GemstoneSwift
import SwiftUI
import Components
import Store
import Style

class AssetSceneViewModel: ObservableObject {
    
    let assetModel: AssetViewModel
    let assetDataModel: AssetDataViewModel
    let walletModel: WalletViewModel
    
    let assetsService: AssetsService
    let transactionsService: TransactionsService
    let stakeService: StakeService
    
    let preferences: SecurePreferences = .standard
    
    init(
        assetsService: AssetsService,
        transactionsService: TransactionsService,
        stakeService: StakeService,
        assetDataModel: AssetDataViewModel,
        walletModel: WalletViewModel
    ) {
        self.assetsService = assetsService
        self.transactionsService = transactionsService
        self.stakeService = stakeService
        self.assetModel = AssetViewModel(asset: assetDataModel.asset)
        self.assetDataModel = assetDataModel
        self.walletModel = walletModel
    }
    
    var transactionsLimit = 50
    
    var title: String {
        return assetModel.name
    }
    
    var assetRequest: AssetRequest {
        return AssetRequest(walletId: walletModel.wallet.id, assetId: assetModel.asset.id.identifier)
    }
    
    var transactionsRequest: TransactionsRequest {
        return TransactionsRequest(walletId: walletModel.wallet.id, type: .asset(assetId: assetModel.asset.id), limit: transactionsLimit)
    }
    
    var headerViewModel: AssetHeaderViewModel {
        return AssetHeaderViewModel(
            assetDataModel: assetDataModel, 
            walletModel: walletModel
        )
    }
    
    var viewAddressOnTitle: String {
        return Localized.Asset.viewAddressOn(ExplorerService.hostName(url: addressExplorerUrl))
    }
    
    var viewTokenOnTitle: String? {
        if let url = tokenExplorerUrl {
            return Localized.Asset.viewTokenOn(ExplorerService.hostName(url: url))
        }
        return .none
    }
    
    var addressExplorerUrl: URL {
        return ExplorerService.addressUrl(
            chain: assetModel.asset.chain,
            address: assetDataModel.address
        )
    }
    
    var tokenExplorerUrl: URL? {
        if let tokenId = assetModel.asset.tokenId {
            return ExplorerService.tokenUrl(
                chain: assetModel.asset.chain,
                address: tokenId
            )
        }
        return .none
    }
    
    var headerTitleView: AssetTitleViewViewModel {
        switch assetModel.asset.id.type {
        case .native:
            return AssetTitleViewViewModel(
                name: assetModel.name,
                chainName: .none,
                tokenTypeName: .none
            )
        case .token:
            return AssetTitleViewViewModel(
                name: assetModel.name,
                chainName: AssetViewModel(asset: assetModel.asset.chain.asset).name,
                tokenTypeName: assetModel.asset.chain.asset.id.assetType?.rawValue
            )
        }
    }
    
    var showPriceView: Bool {
        return !priceView.text.isEmpty && !priceChangeView.text.isEmpty
    }
    
    var showNetwork: Bool {
        true
    }
    
    var showBalances: Bool {
        assetDataModel.showBalances
    }
    
    var showStakedBalance: Bool {
        assetDataModel.isStakeEnabled
    }
    
    var showReservedBalance: Bool {
        assetDataModel.hasReservedBalance
    }
    
    var reservedBalanceUrl: URL? {
        switch assetModel.asset.chain {
        case .xrp: URL(string: "https://xrpl.org/reserves.html")!
        default: .none
        }
    }
    
    var networkField: String { Localized.Transfer.network }
    
    var networkText: String {
        if assetModel.asset.type == .native {
            return assetModel.asset.chain.asset.name
        }
        return "\(assetModel.asset.chain.asset.name) (\(assetModel.asset.type.rawValue))"
    }
    
    var networkAssetImage: AssetImage {
        return AssetIdViewModel(assetId: assetModel.asset.chain.assetId).assetImage
    }
    
    var priceView: TextValueView {
        return TextValueView(
            text: assetDataModel.priceAmountText,
            style: .calloutSecondary)
    }
    
    var priceChangeView: TextValueView {
        return TextValueView(
            text: assetDataModel.priceChangeText,
            style: TextStyle(
                font: .callout,
                color: assetDataModel.priceChangeTextColor,
                background: assetDataModel.priceViewModel.priceChangeTextBackgroundColor
            )
        )
    }
    
    var stakeAprText: String {
        guard let apr = assetDataModel.stakeApr else {
            return .empty
        }
        return Localized.Stake.apr(CurrencyFormatter(type: .percentSignLess).string(apr))
    }
    
    func updateAsset() async {
        do {
            try await assetsService.updateAsset(assetId: assetModel.asset.id)
        } catch {
            NSLog("asset scene: updateAsset error \(error)")
        }
    }
    
    func fetchTransactions() async throws {
        do {
            guard let deviceId = try preferences.get(key: .deviceId) else {
                throw AnyError("deviceId is null")
            }
            try await transactionsService.updateForAsset(deviceId: deviceId, wallet: walletModel.wallet, assetId: assetModel.asset.id)
        } catch {
            NSLog("fetch getTransactions error \(error)")
        }
    }
}
