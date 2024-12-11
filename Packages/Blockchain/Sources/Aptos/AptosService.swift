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
    
    public func fee(destinationAddress: String) async throws -> Fee {
        async let getGasPrice = provider
            .request(.gasPrice)
            .map(as: AptosGasFee.self).prioritized_gas_estimate

        async let getDestinationAccount = getAptosAccount(address: destinationAddress)

        let (gasPrice, destinationAccount) = try await (getGasPrice, getDestinationAccount)
        let isDestinationAccNew = destinationAccount.sequence_number.isEmpty

        // TODO: - gas limit for isDestinationAccNew - not corretcly calculated, when using (max) some dust left
        let gasLimit = Int32(isDestinationAccNew ? 679 : 9)

        return Fee(
            fee: BigInt(gasPrice * gasLimit),
            gasPriceType: .regular(gasPrice: BigInt(gasPrice)),
            gasLimit: BigInt(gasLimit * 2) // * 2 for safety
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
        []
    }

    public func getStakeBalance(for address: String) async throws -> AssetBalance? {
        .none
    }
}

extension AptosService: ChainFeeRateFetchable {
    public func feeRates(type: TransferDataType) async throws -> [FeeRate] {
        FeeRate.defaultRates()
    }
}

// MARK: - ChainTransactionPreloadable

extension AptosService: ChainTransactionPreloadable {
    public func load(input: TransactionInput) async throws -> TransactionPreload {
        async let account = provider.request(.account(address: input.senderAddress))
            .map(as: AptosAccount.self)
        async let fee = fee(destinationAddress: input.feeInput.destinationAddress)
        
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
        throw AnyError("Not Implemented")
    }
    
    public func getIsTokenAddress(tokenId: String) -> Bool {
        false
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
