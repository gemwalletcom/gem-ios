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

    private func getAccount(address: String) async throws -> AptosAccount {
        try await provider
            .request(.account(address: address))
            .mapOrCatch(as: AptosAccount.self, codes: [404], result: .empty)
    }
    
    private func simulateTransaction(sender: String, recipient: String, sequence: String, value: BigInt, gasPrice: BigInt, maxGasAmount: BigInt) async throws -> AptosTransaction {
        let transaction = AptosTransactionSimulation(
            expiration_timestamp_secs: String(Int(Date.now.timeIntervalSince1970) + 1_000_000),
            gas_unit_price: gasPrice.description,
            max_gas_amount: maxGasAmount.description,
            payload: AptosTransactionPayload(
                arguments: [
                    recipient,
                    value.description,
                ],
                function: "0x1::aptos_account::transfer",
                type: "entry_function_payload",
                type_arguments: []
            ),
            sender: sender,
            sequence_number: String(sequence),
            signature: AptosSignature(
                type: "no_account_signature",
                public_key: .none,
                signature: .none
            )
        )
        guard let transaction = try await provider.request(.simulate(transaction)).map(as: [AptosTransaction].self).first else {
            throw AnyError("No aptos transaction")
        }
        return transaction
    }
    
    public func gasLimit(input: TransactionInput, sequence: Int) async throws -> BigInt {
        switch input.type {
        case .transfer(let asset):
            switch asset.id.type {
            case .native:
                let transaction = try await simulateTransaction(
                    sender: input.senderAddress,
                    recipient: input.destinationAddress,
                    sequence: String(sequence),
                    value: input.value,
                    gasPrice: input.gasPrice.gasPrice,
                    maxGasAmount: BigInt(1500)
                )
                return BigInt(stringLiteral: transaction.gas_used)
            case .token:
                return BigInt(1500)
            }
        case .swap: return BigInt(1500)
        case .transferNft, .stake, .generic, .account, .tokenApprove: fatalError()
        }
    }
    
    public func fee(input: TransactionInput, gasPrice: GasPriceType, transferType: TransferDataType, sequence: Int) async throws -> Fee {
        let gasLimit = try await self.gasLimit(input: input, sequence: sequence)
         
        return Fee(
            fee: gasPrice.gasPrice  * gasLimit,
            gasPriceType: .regular(gasPrice: gasPrice.gasPrice),
            gasLimit: gasLimit
        )
    }
}

// MARK: - ChainBalanceable

extension AptosService: ChainBalanceable {
    public func coinBalance(for address: String) async throws -> AssetBalance {
        let resourceName = "0x1::coin::CoinStore<0x1::aptos_coin::AptosCoin>"
        let resource = try await provider.request(.resource(address: address, resource: resourceName))
            .mapOrCatch(
                as: AptosResource<AptosResourceBalance>.self,
                codes: [404],
                result: AptosResource(type: resourceName, data: AptosResourceBalance(coin: AptosResourceCoin(value: "0")))
            )
        
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

extension AptosService: ChainTransactionPreloadable {
    public func preload(input: TransactionPreloadInput) async throws -> TransactionPreload {
        try await TransactionPreload(
            sequence: getAccount(address: input.senderAddress).sequence
        )
    }
}

// MARK: - ChainTransactionPreloadable

extension AptosService: ChainTransactionDataLoadable {
    public func load(input: TransactionInput) async throws -> TransactionData {
        let fee = try await fee(
            input: input,
            gasPrice: input.gasPrice,
            transferType: input.type,
            sequence: input.preload.sequence
        )
        
        return TransactionData(
            sequence: input.preload.sequence,
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
    public func transactionState(for request: TransactionStateRequest) async throws -> TransactionChanges {
        let transaction = try await provider
            .request(.transaction(id: request.id))
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

// MARK: - ChainAddressStatusFetchable

extension AptosService: ChainAddressStatusFetchable {
    public func getAddressStatus(address: String) async throws -> [AddressStatus] {
        []
    }
}

extension AptosAccount {
    static let empty = AptosAccount(sequence_number: "")
    var sequence: Int {
        Int(sequence_number) ?? 0
    }
}
