// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import BigInt
import GemstonePrimitives

public struct XRPService: Sendable {
    
    let chain: Chain
    let provider: Provider<XRPProvider>
    
    public init(
        chain: Chain,
        provider: Provider<XRPProvider>
    ) {
        self.chain = chain
        self.provider = provider
    }
}

// MARK: - Business Logic

extension XRPService {
    private func account(address: String) async throws -> XRPAccount? {
        return try await provider
            .request(.account(address: address))
            .map(as: XRPResult<XRPAccountResult>.self).result.account_data
    }
    
    private func latestBlock() async throws -> BigInt {
        return try await provider
            .request(.latestBlock)
            .map(as: XRPResult<XRPLatestBlock>.self).result.ledger_current_index.asBigInt
    }
    
    private func asset(address: String) async throws -> XRPAssetLine {
        let objects = try await provider
            .request(.accountObjects(address: address))
            .map(as: XRPResult<XRPAccountObjects<[XRPAccountAsset]>>.self).result.account_objects
        guard let asset = objects.first else {
            throw AnyError("Unknown asset")
        }
        return asset.LowLimit
    }
    
    private func reservedBalance() -> BigInt {
        BigInt(chain.accountActivationFee ?? 0)
    }
}

// MARK: - ChainBalanceable

extension XRPService: ChainBalanceable {
    public func coinBalance(for address: String) async throws -> AssetBalance {
        let account = try await account(address: address)
        
        let (available, reserved): (BigInt, BigInt) = {
            if let account = account {
                let balance = BigInt(stringLiteral: account.Balance)
                let reserved = reservedBalance()
                return (
                    max(balance - reserved, .zero),
                    reserved
                )
            } else {
                return (.zero, .zero)
            }
        }()
        
        return Primitives.AssetBalance(
            assetId: chain.assetId,
            balance: Balance(
                available: available,
                reserved: reserved
            )
        )
    }
    
    public func tokenBalance(for address: String, tokenIds: [AssetId]) async throws -> [AssetBalance] {
        []
    }

    public func getStakeBalance(for address: String) async throws -> AssetBalance? {
        .none
    }
}

extension XRPService: ChainFeeRateFetchable {
    public func feeRates(type: TransferDataType) async throws -> [FeeRate] {
        let fees = try await provider
            .request(.fee)
            .map(as: XRPResult<XRPFee>.self).result
        
        let minimumFee = BigInt(stringLiteral: fees.drops.minimum_fee)
        let medianFee = BigInt(stringLiteral: fees.drops.median_fee)
    
        return [
            FeeRate(priority: .slow, gasPriceType: .regular(gasPrice: max(medianFee / 10, minimumFee))),
            FeeRate(priority: .normal, gasPriceType: .regular(gasPrice: medianFee)),
            FeeRate(priority: .fast, gasPriceType: .regular(gasPrice: medianFee * 2)),
        ]
    }
}

extension XRPService: ChainTransactionPreloadable {
    public func preload(input: TransactionPreloadInput) async throws -> TransactionPreload {
        try await TransactionPreload(
            sequence: (account(address: input.senderAddress)?.Sequence)?.asInt ?? 0
        )
    }
}

// MARK: - ChainTransactionPreloadable

extension XRPService: ChainTransactionLoadable {
    public func load(input: TransactionInput) async throws -> TransactionLoad {
        return TransactionLoad(
            sequence: input.preload.sequence,
            fee: input.defaultFee
        )
    }
}

// MARK: - ChainBroadcastable

extension XRPService: ChainBroadcastable {
    public func broadcast(data: String, options: BroadcastOptions) async throws -> String {
        let result = try await provider
            .request(.broadcast(data: data))
            .map(as: XRPResult<XRPTransactionBroadcast>.self).result
        
        if let message = result.engine_result_message, !message.isEmpty, result.accepted == false  {
            throw AnyError(message)
        } else if let message = result.error_exception {
            throw AnyError(message)
        }
        guard let hash = result.tx_json?.hash else {
            throw AnyError("Unable to get hash")
        }
        
        return hash
    }
}

// MARK: - ChainTransactionStateFetchable

extension XRPService: ChainTransactionStateFetchable {
    public func transactionState(for request: TransactionStateRequest) async throws -> TransactionChanges {
        let status = try await provider
            .request(.transaction(id: request.id))
            .map(as: XRPResult<XRPTransactionStatus>.self).result.status
        let state: TransactionState = status == "success" ? .confirmed : .pending
        return TransactionChanges(state: state)
    }
}

// MARK: - ChainSyncable

extension XRPService: ChainSyncable {
    public func getInSync() async throws -> Bool {
        //TODO: Add getInSync check later
        true
    }
}

// MARK: - ChainStakable

extension XRPService: ChainStakable {
    public func getValidators(apr: Double) async throws -> [DelegationValidator] {
        return []
    }

    public func getStakeDelegations(address: String) async throws -> [DelegationBase] {
        fatalError()
    }
}

// MARK: - ChainTokenable

extension XRPService: ChainTokenable {
    public func getTokenData(tokenId: String) async throws -> Asset {
        let asset = try await asset(address: tokenId)
        let currency = try Data.from(hex: asset.currency.trimmingCharacters(in: CharacterSet(charactersIn: "0")))
        guard let symbol = String(data: currency, encoding: .ascii) else {
            throw AnyError("invalid symbol")
        }
        
        return Asset(
            id: AssetId(chain: chain, tokenId: tokenId),
            name: symbol,
            symbol: symbol,
            decimals: 15, //TODO: Default?
            type: .token
        )
    }
    
    public func getIsTokenAddress(tokenId: String) -> Bool {
        false
        //tokenId.hasPrefix("r")
    }
}

// MARK: - ChainIDFetchable
 
extension XRPService: ChainIDFetchable {
    public func getChainID() async throws -> String {
        //TODO: Add getChainID check later
        return ""
    }
}

// MARK: - ChainLatestBlockFetchable

extension XRPService: ChainLatestBlockFetchable {
    public func getLatestBlock() async throws -> BigInt {
        try await latestBlock()
    }
}


// MARK: - ChainAddressStatusFetchable

extension XRPService: ChainAddressStatusFetchable {
    public func getAddressStatus(address: String) async throws -> [AddressStatus] {
        []
    }
}
