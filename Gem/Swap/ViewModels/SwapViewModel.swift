// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Components
import ExplorerService
import Foundation
import GemstonePrimitives
import GRDBQuery
import Keystore
import Localization
import Preferences
import Primitives
import PrimitivesComponents
import Signer
import Store
import Style
import Swap
import SwapService
import SwiftUI
import Transfer
import WalletsService
import PrimitivesComponents
import Preferences
import AssetsService

import class Gemstone.Config
import struct Gemstone.Permit2ApprovalData
import struct Gemstone.Permit2Data
import func Gemstone.permit2DataToEip712Json
import struct Gemstone.Permit2Detail
import struct Gemstone.PermitSingle
import enum Gemstone.SwapProvider
import struct Gemstone.SwapQuote
import struct Gemstone.SwapQuoteData
import struct Gemstone.SwapQuoteRequest
import struct Swap.ErrorWrapper
import struct Swap.SwapAvailabilityResult
import class Swap.SwapPairSelectorViewModel

typealias SelectAssetSwapTypeAction = ((SelectAssetSwapType) -> Void)?

@Observable
class SwapViewModel {
    static let quoteTaskDebounceTimeout = Duration.milliseconds(150)

    let keystore: any Keystore
    let walletsService: WalletsService
    let assetService: AssetsService

    var wallet: Wallet

    var fromAssetRequest: AssetRequestOptional
    var toAssetRequest: AssetRequestOptional

    var pairSelectorModel: SwapPairSelectorViewModel?
    var selectedProvider: SwapProvider?
    var fromValue: String = ""
    var toValue: String = ""

    var swapState: SwapState = .init()

    let explorerService: any ExplorerLinkFetchable = ExplorerService.standard

    private let preferences: Preferences
    private let swapService: SwapService
    private let formatter = ValueFormatter(style: .full)

    init(
        preferences: Preferences = Preferences.standard,
        wallet: Wallet,
        pairSelectorModel: SwapPairSelectorViewModel?,
        walletsService: WalletsService,
        swapService: SwapService,
        keystore: any Keystore,
        assetService: AssetsService
    ) {
        self.preferences = preferences
        self.wallet = wallet
        self.pairSelectorModel = pairSelectorModel
        self.keystore = keystore
        self.walletsService = walletsService
        self.swapService = swapService
        self.assetService = assetService

        fromAssetRequest = AssetRequestOptional(walletId: wallet.walletId.id, assetId: pairSelectorModel?.fromAssetId?.identifier)
        toAssetRequest = AssetRequestOptional(walletId: wallet.walletId.id, assetId: pairSelectorModel?.toAssetId?.identifier)
    }

    var title: String { Localized.Wallet.swap }

    var swapFromTitle: String { Localized.Swap.youPay }
    var swapToTitle: String { Localized.Swap.youReceive }
    var errorTitle: String { Localized.Errors.errorOccured }

    var providerField: String { Localized.Common.provider }
    var providerText: String? {
        if case .loaded(let result) = swapState.availability,
            let quote = result.quotes.first(where: { $0.data.provider == selectedProvider }) {
            return SwapProviderViewModel(provider: quote.data.provider).providerText
        }
        return .none
    }

    var providerImage: AssetImage? {
        if case .loaded(let result) = swapState.availability,
            let quote = result.quotes.first(where: { $0.data.provider == selectedProvider }) {
            return SwapProviderViewModel(provider: quote.data.provider).providerImage
        }
        return .none
    }

    var actionButtonState: StateViewType<SwapAvailabilityResult> {
        switch swapState.getQuoteData {
        case .loading: .loading
        case .error(let error): .error(error)
        case .noData, .loaded: swapState.availability
        }
    }

    var isSwitchAssetButtonDisabled: Bool {
        swapState.availability.isLoading || swapState.getQuoteData.isLoading
    }
    
    var allowSelectProvider: Bool {
        if case .loaded(let result) = swapState.availability {
            return result.quotes.count > 1
        }
        return false
    }
    
    var swapQuotes: [SwapQuote] {
        if case .loaded(let result) = swapState.availability {
            return result.quotes
        }
        return []
    }

    func showToValueLoading() -> Bool {
        swapState.availability.isLoading
    }

    func actionButtonTitle(fromAsset: Asset) -> String {
        switch swapState.availability {
        case .noData, .loading:
            return Localized.Wallet.swap
        case .loaded:
            return Localized.Wallet.swap
        case .error:
            return Localized.Common.tryAgain
        }
    }

    func shouldDisableActionButton(fromAsset: Asset) -> Bool {
        !isValidValue(fromAsset: fromAsset)
    }

    func swapTokenModel(from assetData: AssetData, type: SelectAssetSwapType) -> SwapTokenViewModel {
        SwapTokenViewModel(
            model: AssetDataViewModel(assetData: assetData, formatter: .medium, currencyCode: preferences.currency),
            type: type
        )
    }

    func assetIds(_ fromAsset: AssetData?, _ toAsset: AssetData?) -> [AssetId] {
        [fromAsset?.asset.id, toAsset?.asset.id].compactMap { $0 }
    }

    func priceImpactViewModel(_ fromAsset: AssetData?, _ toAsset: AssetData?) -> PriceImpactViewModel? {
        guard
            case .loaded(let result) = swapState.availability,
            let quote = result.quotes.first(where: { $0.data.provider == selectedProvider }),
            let fromAsset,
            let toAsset
        else {
            return nil
        }
        return PriceImpactViewModel(
            fromAssetData: fromAsset,
            fromValue: quote.fromValue,
            toAssetData: toAsset,
            toValue: quote.toValue
        )
    }
    
    func refresh(for wallet: Wallet) {
        self.wallet = wallet
        pairSelectorModel = nil
        setupSwapPairSelector()
        fromAssetRequest = AssetRequestOptional(
            walletId: wallet.id,
            assetId: pairSelectorModel?.fromAssetId?.identifier
        )
        toAssetRequest = AssetRequestOptional(
            walletId: wallet.id,
            assetId: pairSelectorModel?.toAssetId?.identifier
        )
    }
    
    func setupSwapPairSelector() {
        guard pairSelectorModel == nil else { return }
        let asset = try? assetService.getAssets(walletID: wallet.id, filters: [.hasBalance]).first
        pairSelectorModel = SwapPairSelectorViewModel.defaultSwapPair(for: asset?.asset)
}
    func swapProvidersViewModel(asset: Asset) -> SwapProvidersViewModel {
        SwapProvidersViewModel(
            items: swapQuotes.sorted(by: {
                (try? BigInt.from(string: $0.toValue) > BigInt.from(string: $1.toValue)) == true
            }).map { SwapProviderItem(asset: asset, swapQuote: $0) }
        )
    }
}

// MARK: - Business Logic

extension SwapViewModel {
    func resetValues() {
        resetToValue()
        fromValue = ""
    }

    func resetToValue() {
        toValue = ""
    }

    func setMaxFromValue(asset: Asset, value: BigInt) {
        fromValue = formatter.string(value, decimals: asset.decimals.asInt)
    }

    func onFetchStateChange(state: SwapFetchState) async {
        switch state {
        case .fetch(let input, _):
            guard let fromAsset = input.fromAsset, let toAsset = input.toAsset else { return }
            await fetch(
                fromAsset: fromAsset.asset,
                toAsset: toAsset.asset,
                amount: input.amount
            )
        case .idle: break
        }
    }

    func onAssetIdsChange(assetIds: [AssetId]) async {
        await updateAssets(assetIds: assetIds)
    }

    func swapData(fromAsset: Asset, toAsset: Asset) async -> TransferData? {
        guard
            case .loaded(let swapAvailability) = swapState.availability,
            let quote = swapAvailability.quotes.first(where: { $0.data.provider == selectedProvider })
        else {
            return nil
        }
        do {
            swapState.getQuoteData = .loading
            let data = try await getSwapData(
                fromAsset: fromAsset,
                toAsset: toAsset,
                quote: quote
            )
            swapState.getQuoteData = .noData
            return data
        } catch {
            swapState.getQuoteData = .error(ErrorWrapper(error))
            swapState.availability = .error(ErrorWrapper(error))
        }
        return nil
    }
    
    func reset() {
        swapState = .init()
        resetValues()
    }
    
    func updateToValue(
        for provider: SwapProvider,
        asset: Asset
    ) {
        guard
            case .loaded(let result) = swapState.availability,
            let bestRate = result.quotes.first(where: { $0.data.provider == provider }),
            let value = try? BigInt.from(string: bestRate.toValue)
        else {
            return
        }
        toValue = formatter.string(value, decimals: asset.decimals.asInt)
    }
}

// MARK: - Private

extension SwapViewModel {
    private func isValidValue(fromAsset: Asset) -> Bool {
        guard !fromValue.isEmpty else { return false }
        let amount = (try? formatter.inputNumber(from: fromValue, decimals: Int(fromAsset.decimals))) ?? BigInt.zero

        return amount > 0
    }

    private func fetch(
        fromAsset: Asset,
        toAsset: Asset,
        amount: String
    ) async {
        let shouldFetch: Bool = await MainActor.run { [self] in
            resetToValue()
            if !self.isValidValue(fromAsset: fromAsset) {
                self.swapState.availability = .noData
                return false
            }
            self.swapState.availability = .loading
            return true
        }

        guard shouldFetch else { return }

        do {
            let swapQuotes = try await getQuote(fromAsset: fromAsset, toAsset: toAsset, amount: amount)

            await MainActor.run {
                swapState.availability = .loaded(SwapAvailabilityResult(quotes: swapQuotes))
                if let selectedProvider {
                    updateToValue(for: selectedProvider, asset: toAsset)
                } else {
                    setBestProvider(toAsset: toAsset)
                }
            }
        } catch {
            await MainActor.run { [self] in
                if !error.isCancelled {
                    self.swapState.availability = .error(ErrorWrapper(error))
                    NSLog("fetch asset data error: \(error)")
                }
            }
        }
    }

    private func updateAssets(assetIds: [AssetId]) async {
        async let prices: () = try walletsService.updatePrices(assetIds: assetIds)
        async let balances: () = try walletsService.updateBalance(for: wallet.walletId, assetIds: assetIds)

        do {
            _ = try await [prices, balances]
        } catch {
            // TODO: - handle error
            print("SwapScene updateAssets error: \(error)")
        }
    }

    private func getSwapData(fromAsset: Asset, toAsset: Asset, quote: SwapQuote) async throws -> TransferData {
        let quoteData = try await getQuoteData(quote: quote)
        let value = BigInt(stringLiteral: quote.request.value)
        let recepientData = RecipientData(
            recipient: Recipient(name: quote.data.provider.name, address: quoteData.to, memo: .none),
            amount: .none
        )
        return TransferData(type: .swap(fromAsset, toAsset, quote, quoteData), recipientData: recepientData, value: value, canChangeValue: true)
    }

    private func getQuote(fromAsset: Asset, toAsset: Asset, amount: String) async throws -> [SwapQuote] {
        let value = try formatter.inputNumber(from: amount, decimals: Int(fromAsset.decimals))
        let walletAddress = try wallet.account(for: fromAsset.chain).address
        let destinationAddress = try wallet.account(for: toAsset.chain).address
        return try await swapService.getQuotes(
            fromAsset: fromAsset.id,
            toAsset: toAsset.id,
            value: value.description,
            walletAddress: walletAddress,
            destinationAddress: destinationAddress
        )
    }
    
    private func setBestProvider(toAsset: Asset) {
        guard
            case .loaded(let result) = swapState.availability,
            let bestRate = try? result.quotes.sorted(by: {
                try BigInt.from(string: $0.toValue) > BigInt.from(string: $1.toValue)
            }).first,
            let value = try? BigInt.from(string: bestRate.toValue)
        else {
            return
        }
        
        toValue = formatter.string(value, decimals: toAsset.decimals.asInt)
        selectedProvider = bestRate.data.provider
    }

    private func getQuoteData(quote: SwapQuote) async throws -> SwapQuoteData {
        switch try await swapService.getPermit2Approval(quote: quote) {
        case .none:
            return try await swapService.getQuoteData(quote, data: .none)
        case .some(let data):
            let chain = try AssetId(id: quote.request.fromAsset).chain
            let data = try permitData(chain: chain, data: data)
            return try await swapService.getQuoteData(quote, data: .permit2(data))
        }
    }

    public func permitData(chain: Chain, data: Permit2ApprovalData) throws -> Permit2Data {
        let permit2Single = permit2Single(
            token: data.token,
            spender: data.spender,
            value: data.value,
            nonce: data.permit2Nonce
        )
        let permit2JSON = try Gemstone.permit2DataToEip712Json(
            chain: chain.rawValue,
            data: permit2Single,
            contract: data.permit2Contract
        )
        let signer = Signer(wallet: wallet, keystore: keystore)
        let signature = try signer.signMessage(
            chain: chain,
            message: .typed(permit2JSON)
        )
        return try Permit2Data(
            permitSingle: permit2Single,
            signature: Data.from(hex: signature)
        )
    }

    public func permit2Single(token: String, spender: String, value: String, nonce: UInt64) -> Gemstone.PermitSingle {
        let config = Config.shared.getSwapConfig()
        let now = Date().timeIntervalSince1970
        return PermitSingle(
            details: Permit2Detail(
                token: token,
                amount: value,
                expiration: UInt64(now) + config.permit2Expiration,
                nonce: nonce
            ),
            spender: spender,
            sigDeadline: UInt64(now) + config.permit2SigDeadline
        )
    }

    public func getAssetsForPayAssetId(assetId: AssetId) -> ([Primitives.Chain], [Primitives.AssetId]) {
        swapService.supportedAssets(for: assetId)
    }
}

extension Gemstone.SwapProvider {
    var image: Image {
        switch self {
        case .uniswapV3, .uniswapV4: Images.SwapProviders.uniswap
        case .jupiter: Images.SwapProviders.jupiter
        case .orca: Images.SwapProviders.orca
        case .pancakeSwapV3, .pancakeSwapAptosV2: Images.SwapProviders.pancakeswap
        case .thorchain: Images.SwapProviders.thorchain
        case .across: Images.SwapProviders.across
        case .okuTrade: Images.SwapProviders.oku
        }
    }
}
