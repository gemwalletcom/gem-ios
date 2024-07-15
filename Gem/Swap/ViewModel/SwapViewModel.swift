// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import BigInt
import Keystore
import Components
import SwiftUI
import GRDBQuery

class SwapViewModel: ObservableObject {
    
    let wallet: Wallet
    
    let keystore: any Keystore
    let walletService: WalletService
    let service: SwapService
    
    @Published var fromAssetRequest: AssetRequest
    @Published var toAssetRequest: AssetRequest
    @Published var tokenApprovalsRequest: TransactionsRequest
    
    private let quoteTaskDebounceTimeout = Duration.milliseconds(300)
    internal var quoteTask: Task<SwapQuote, Error>?

    @Published var fromValue: String = ""
    @Published var toValue: String = ""
    
    @Published var quoteState: StateViewType<()> = .noData
    @Published var allowanceState: StateViewType<Bool> = .loading
    
    private let formatter = ValueFormatter(style: .full)
    
    init(
        wallet: Wallet,
        keystore: any Keystore,
        walletService: WalletService,
        assetId: AssetId,
        service: SwapService
    ) {
        self.wallet = wallet
        self.keystore = keystore
        self.walletService = walletService
        self.service = service
        
        // temp code
        let fromId: AssetId
        let toId: AssetId
        if assetId.type == .native {
            //TODO: Swap. Support later
            fatalError()
        } else {
            fromId = assetId.chain.assetId
            toId = assetId
        }
        
        fromAssetRequest = AssetRequest(walletId: wallet.id, assetId: fromId.identifier)
        toAssetRequest = AssetRequest(walletId: wallet.id, assetId: toId.identifier)
        tokenApprovalsRequest = TransactionsRequest(
            walletId: wallet.id,
            type: .assetsTransactionType(assetIds: [fromId, toId], type: .tokenApproval, states: [.pending]),
            limit: 2
        )
    }
    
    var title: String {
        return Localized.Wallet.swap
    }
    
    func resetValues() {
        toValue = ""
        fromValue = ""
    }

    func useFromMax(asset: Asset, value: BigInt) {
        fromValue = formatter.string(value, decimals: asset.decimals.asInt)
    }
    
    private func request(_ fromAsset: Asset, _ toAsset: Asset, _ amount: String, includeData: Bool) throws -> SwapQuoteRequest {
        let amount = try formatter.inputNumber(from: amount, decimals: Int(fromAsset.decimals))
        guard amount > 0 else {
            throw AnyError("amount should be more than 0")
        }
        let walletAddress = try wallet.account(for: fromAsset.chain).address
        let destinationAddress = try wallet.account(for: toAsset.chain).address
        
        return SwapQuoteRequest(
            fromAsset: fromAsset.id.identifier,
            toAsset: toAsset.id.identifier,
            walletAddress: walletAddress,
            destinationAddress: destinationAddress,
            amount: amount.description,
            includeData: includeData
        )
    }
    
    
    func get_quote(fromAsset: Asset, toAsset: Asset, amount: String) {
        quoteTask?.cancel()
        
        self.toValue = ""
        
        if amount.isEmpty {
            self.quoteState = .noData
            return
        }
        
        DispatchQueue.main.async {
            self.quoteState = .loading
        }
        
        Task {
            do {
                let task = Task.detached {
                    try await Task.sleep(for: self.quoteTaskDebounceTimeout)
                    return try await self.quote(fromAsset: fromAsset, toAsset: toAsset, amount: amount)
                }
                quoteTask = task
                let value = try await task.value.toValue

                DispatchQueue.main.async {
                    self.toValue = self.formatter.string(value, decimals: toAsset.decimals.asInt)
                    self.quoteState = .loaded(())
                }
                try await updateAllowance(fromAsset: fromAsset)
            } catch {
                if error.isCancelled {
                    return
                }
                
                NSLog("swap quote error: \(error)")
                
                DispatchQueue.main.async {
                    self.quoteState = .error(error)
                }
            }
        }
    }
    
    func updateAllowance(fromAsset: Asset) async throws {
        switch fromAsset.type {
        case .native, .spl, .token:
            DispatchQueue.main.async {
                self.allowanceState = .loaded(true)
            }
        case .bep20, .erc20:
            DispatchQueue.main.async {
                self.allowanceState = .loading
            }

            let address = try wallet.account(for: fromAsset.chain).address
            let spender = try await SwapService.getSpender(chain: fromAsset.chain, quote: quoteTask?.value)
            let allowance = try await service.getAllowance(chain: fromAsset.chain, contract: try fromAsset.getTokenId(), owner: address, spender: spender)
            DispatchQueue.main.async {
                self.allowanceState = .loaded(!allowance.isZero)
            }
            NSLog("allowance \(allowance)")
        case .trc20, .ibc, .jetton, .synth:
            fatalError()
        }
    }
    
    func getAllowanceData(fromAsset: Asset, toAsset: Asset, spender: String, spenderName: String) throws -> TransferData {
        return TransferData(
            type: .swap(
                fromAsset,
                toAsset,
                SwapAction.approval(spender: spender, allowance: .MAX_256)
            ),
            recipientData: RecipientData(
                asset: fromAsset,
                recipient: Recipient(name: spenderName, address: try fromAsset.getTokenId(), memo: .none)
            ),
            value: BigInt.zero
        )
    }
    
    // used to fetch quote estimates. without any data
    func quote(fromAsset: Asset, toAsset: Asset, amount: String) async throws -> SwapQuote {
        let request = try self.request(fromAsset, toAsset, amount, includeData: false)
        return try await service.getQuote(request: request).quote
    }

    // used to fetch quote data for swaps
    func swap(fromAsset: Asset, toAsset: Asset, amount: String) async throws -> TransferData {
        let request = try self.request(fromAsset, toAsset, amount, includeData: true)
        
        let quote = try await service.getQuote(request: request).quote
        guard let data = quote.data else {
            throw AnyError("")
        }
        let swapData = SwapData(quote: quote)
        
        return TransferData(
            type: .swap(
                fromAsset,
                toAsset,
                .swap(swapData)
            ),
            recipientData: RecipientData(
                asset: fromAsset,
                recipient: Recipient(name: quote.provider.name, address: data.to, memo: .none)
            ),
            value: BigInt(stringLiteral: request.amount)
        )
    }
    
    func updateAssets(assetIds: [AssetId]) async throws {
        async let prices: () = try walletService.updatePrices(assetIds: assetIds)
        async let balances: () = try walletService.updateBalance(for: wallet, assetIds: assetIds)
        let _ = try await [prices, balances]
    }
}
