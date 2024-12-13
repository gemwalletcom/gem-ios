// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import BigInt

public struct AptosService: Sendable {
    let chain: Chain
    let provider: Provider<AptosProvider>
    
    public init(
        chain: Chain,
        provider: Provider<AptosProvider>
    ) {
        self.chain = chain
        self.provider = provider
    }
    
    private func getLedger() async throws -> AptosLedger {
        try await provider.request(.ledger)
            .map(as: AptosLedger.self)
    }

    private func getAptosAccount(address: String) async throws -> AptosAccount {
        do {
            return try await provider
                .request(.account(address: address))
                .mapOrError(
                    as: AptosAccount.self,
                    asError: AptosError.self
                )
        } catch let apiError as AptosError {
            let code = AptosErrorCode(rawValue: apiError.error_code)
            switch code {
            case .accountNotFound:
                return AptosAccount(sequence_number: "")
            case .none:
                throw apiError
            }
        }
    }
    
    public func fee(gasPrice: GasPriceType, transferType: TransferDataType, destinationAddress: String) async throws -> Fee {
        async let getDestinationAccount = getAptosAccount(address: destinationAddress)

        let destinationAccount = try await getDestinationAccount
        let isDestinationAccNew = destinationAccount.sequence_number.isEmpty
        
        // TODO: - gas limit for isDestinationAccNew - not corretcly calculated, when using (max) some dust left

        let gasLimit = switch transferType {
            case .transfer(let asset):
            switch asset.id.type {
            case .native: isDestinationAccNew ? BigInt(679) : BigInt(9)
            case .token: BigInt(1000)
            }
            case .swap, .stake, .generic: fatalError()
        }
         
        return Fee(
            fee: gasPrice.gasPrice  * gasLimit,
            gasPriceType: .regular(gasPrice: gasPrice.gasPrice),
            gasLimit: gasLimit * 2 // * 2 for safety
        )
    }
}

// MARK: - ChainBalanceable

extension AptosService: ChainBalanceable {
    public func coinBalance(for address: String) async throws -> AssetBalance {
        let resource = try await provider.request(.balance(address: address))
            .map(as: AptosResource<AptosResourceBalance>.self)
        
        let balance = BigInt(stringLiteral: resource.data.coin.value)
        return AssetBalance(assetId: chain.assetId, balance: Balance(available: balance))
    }
    
    public func tokenBalance(for address: String, tokenIds: [AssetId]) async throws -> [AssetBalance] {
        let resources = try await provider.request(.resources(address: address))
            .map(as: [AptosResource<AptosResourceBalanceOptional>].self)
        
        return tokenIds.compactMap { assetId in
            if let tokenId = assetId.tokenId, let resource = resources.first(where: { $0.type == "0x1::coin::CoinStore<\(tokenId)>" }), let balance = resource.data.coin {
                return AssetBalance(
                    assetId: assetId,
                    balance: Balance(available: BigInt(stringLiteral: balance.value))
                )
            }
            return .none
        }
    }

    public func getStakeBalance(for address: String) async throws -> AssetBalance? {
        .none
    }
}

extension AptosService: ChainFeeRateFetchable {
    public func feeRates(type: TransferDataType) async throws -> [FeeRate] {
        let gasPrice = try await provider
            .request(.gasPrice)
            .map(as: AptosGasFee.self)
        
        return [
            FeeRate(priority: .slow, gasPriceType: .regular(gasPrice: BigInt(gasPrice.gas_estimate))),
            FeeRate(priority: .normal, gasPriceType: .regular(gasPrice: BigInt(gasPrice.prioritized_gas_estimate))),
            FeeRate(priority: .fast, gasPriceType: .regular(gasPrice: BigInt(gasPrice.prioritized_gas_estimate * 2))),
        ]
    }
}

// MARK: - ChainTransactionPreloadable

extension AptosService: ChainTransactionPreloadable {
    public func load(input: TransactionInput) async throws -> TransactionPreload {
        async let account = provider.request(.account(address: input.senderAddress))
            .map(as: AptosAccount.self)
        
        async let fee = fee(
            gasPrice: input.gasPrice,
            transferType: input.type,
            destinationAddress: input.feeInput.destinationAddress
        )
        
        return try await TransactionPreload(
            sequence: Int(account.sequence_number) ?? 0,
            fee: fee
        )
    }
}

// MARK: - ChainBroadcastable

extension AptosService: ChainBroadcastable {
    public func broadcast(data: String, options: BroadcastOptions) async throws -> String {
        return try await provider
            .request(.broadcast(data: data))
            .map(as: AptosTransactionBroacast.self).hash
    }
}

// MARK: - ChainTransactionStateFetchable

extension AptosService: ChainTransactionStateFetchable {
    public func transactionState(for id: String, senderAddress: String) async throws -> TransactionChanges {
        let transaction = try await provider
            .request(.transaction(id: id))
            .map(as: AptosTransaction.self)

        let state: TransactionState = transaction.success ? .confirmed : .reverted
        let fee = BigInt(stringLiteral: transaction.gas_used) * BigInt(stringLiteral: transaction.gas_unit_price)

        return TransactionChanges(
            state: state,
            changes: [.networkFee(fee)]
        )
    }
}

// MARK: - ChainSyncable

extension AptosService: ChainSyncable {
    public func getInSync() async throws -> Bool {
        //TODO: Add getInSync check later
        true
    }
}

// MARK: - ChainStakable

extension AptosService: ChainStakable {
    public func getValidators(apr: Double) async throws -> [DelegationValidator] {
        return []
    }

    public func getStakeDelegations(address: String) async throws -> [DelegationBase] {
        fatalError()
    }
}

// MARK: - ChainTokenable

extension AptosService: ChainTokenable {
    public func getTokenData(tokenId: String) async throws -> Asset {
        let parts: [String] = tokenId.split(separator: "::").map { String($0) }
        let address = try parts.getElement(safe: 0)
        let resource = "0x1::coin::CoinInfo<\(tokenId)>"
        
        let tokenInfo = try await provider
            .request(.resource(address: address, resource: resource))
            .map(as: AptosResource<AptosCoinInfo>.self).data
        
        return Asset(
            id: AssetId(chain: .aptos, tokenId: tokenId),
            name: tokenInfo.name,
            symbol: tokenInfo.symbol,
            decimals: tokenInfo.decimals,
            type: .token
        )
    }
    
    public func getIsTokenAddress(tokenId: String) -> Bool {
        tokenId.hasPrefix("0x") && tokenId.contains("::")
    }
}

// MARK: - ChainIDFetchable
 
extension AptosService: ChainIDFetchable {
    public func getChainID() async throws -> String {
        try await getLedger().chain_id.asString
    }
}

// MARK: - ChainLatestBlockFetchable

extension AptosService: ChainLatestBlockFetchable {
    public func getLatestBlock() async throws -> BigInt {
        let ledger = try await getLedger()
        return BigInt(stringLiteral: ledger.ledger_version)
    }
}

extension AptosError: LocalizedError {
    public var errorDescription: String? {
        message
    }
}

// MARK: - ChainAddressStatusFetchable

extension AptosService: ChainAddressStatusFetchable {
    public func getAddressStatus(address: String) async throws -> [AddressStatus] {
        []
    }
}
