// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import BigInt
import GemstonePrimitives
import WalletCore

public struct CardanoService: Sendable {
    
    let chain: Chain
    let graphql: GraphqlService
    
    public init(
        chain: Chain,
        graphql: GraphqlService
    ) {
        self.chain = chain
        self.graphql = graphql
    }
}

// MARK: - Business Logic

extension CardanoService {
    private func latestBlock() async throws -> BigInt {
        let request = GraphqlRequest(
            operationName: "GetBlockNumber",
            variables: [:],
            query: "query GetBlockNumber { cardano { tip { number } } }"
        )
        let result: CardanoBlockData = try await graphql.requestData(request)
        return BigInt(result.cardano.tip.number)
    }
    
    private func balance(address: String) async throws -> BigInt {
        let request = GraphqlRequest(
            operationName: "GetBalance",
            variables: ["address": address],
            query: "query GetBalance($address: String!) { utxos: utxos_aggregate(where: { address: { _eq: $address }  } ) { aggregate { sum { value } } } }"
        )
        let result: CardanoUTXOS<CardanoAggregateBalance> = try await graphql.requestData(request)
        if let value = result.utxos.aggregate.sum.value {
            return BigInt(stringLiteral: value)
        }
        return .zero
    }
    
    private func transaction(hash: String) async throws -> CardanoTransaction {
        let request = GraphqlRequest(
            operationName: "TransactionsByHash",
            variables: ["hash": hash],
            query: "query TransactionsByHash($hash: Hash32Hex!) { transactions(where: { hash: { _eq: $hash }  } ) { block { number } fee } }"
        )
        let result: CardanoTransactions = try await graphql.requestData(request)
        if let transaction = result.transactions.first {
            return transaction
        }
        throw AnyError("no transaction for hash \(hash)")
    }
    
    private func utxos(address: String) async throws -> [UTXO] {
        let request = GraphqlRequest(
            operationName: "UtxoSetForAddress",
            variables: ["address": address],
            query: "query UtxoSetForAddress($address: String!) { utxos(order_by: { value: desc } , where: { address: { _eq: $address }  } ) { address value txHash index tokens { quantity asset { fingerprint policyId assetName } } } }"
        )
        let result: CardanoUTXOS<[CardanoUTXO]> = try await graphql.requestData(request)
        return result.utxos.map {
            UTXO(transaction_id: $0.txHash, vout: $0.index, value: $0.value, address: $0.address)
        }
    }
    
    private func broadcast(data: String) async throws -> GraphqlData<CardanoTransactionBroadcast> {
        let request = GraphqlRequest(
            operationName: "SubmitTransaction",
            variables: ["transaction": data],
            query: "mutation SubmitTransaction($transaction: String!) { submitTransaction(transaction: $transaction) { hash } }"
        )
        return try await graphql.request(request)
    }
    
    private func networkMagic() async throws -> BigInt {
        let request = GraphqlRequest(
            operationName: "GetNetworkMagic",
            variables: [:],
            query: "query GetNetworkMagic { genesis { shelley { networkMagic } } }"
        )
        let result: CardanoGenesisData = try await graphql.requestData(request)
        return BigInt(result.genesis.shelley.networkMagic)
    }

    private func calculateFee(input: TransactionInput, utxos: [UTXO]) throws -> BigInt {
        let signingInput = try CardanoSigningInput.with {
            $0.utxos = try utxos.map { utxo in
                try CardanoTxInput.with {
                    $0.outPoint.txHash = try Data.from(hex: utxo.transaction_id)
                    $0.outPoint.outputIndex = UInt64(utxo.vout)
                    $0.address = utxo.address
                    $0.amount = try UInt64(string: utxo.value)
                }
            }
            $0.transferMessage.toAddress = input.destinationAddress
            $0.transferMessage.changeAddress = input.senderAddress
            $0.transferMessage.amount = input.value.asUInt
            $0.transferMessage.useMaxAmount = input.value == input.balance
            $0.ttl = 190000000
        }
        let plan: CardanoTransactionPlan = AnySigner.plan(input: signingInput, coin: .cardano)
        return BigInt(plan.fee)
    }
}

// MARK: - ChainBalanceable

extension CardanoService: ChainBalanceable {
    public func coinBalance(for address: String) async throws -> AssetBalance {
        let available = try await balance(address: address)
        
        return Primitives.AssetBalance(
            assetId: chain.assetId,
            balance: Balance(
                available: available
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

extension CardanoService: ChainFeeRateFetchable {
    public func feeRates(type: TransferDataType) async throws -> [FeeRate] {
        return [
            FeeRate(priority: .normal, gasPriceType: .regular(gasPrice: 1)),
        ]
    }
}

extension CardanoService: ChainTransactionPreloadable {
    public func preload(input: TransactionPreloadInput) async throws -> TransactionPreload {
        .none
    }
}

// MARK: - ChainTransactionPreloadable

extension CardanoService: ChainTransactionLoadable {
    public func load(input: TransactionInput) async throws -> TransactionLoad {
        let utxos = try await utxos(address: input.senderAddress)
        let fee = try calculateFee(input: input, utxos: utxos)
        
        return TransactionLoad(
            fee: Fee(fee: fee, gasPriceType: .regular(gasPrice: 1), gasLimit: 1),
            utxos: utxos
        )
    }
}

// MARK: - ChainBroadcastable

extension CardanoService: ChainBroadcastable {
    public func broadcast(data: String, options: BroadcastOptions) async throws -> String {
        let transaction = try await self.broadcast(data: data)
        
        if let error = transaction.errors?.first {
            throw AnyError(error.message)
        } else if let transaction = transaction.data?.submitTransaction {
            return transaction.hash
        }

        throw ChainServiceErrors.broadcastError(chain)
    }
}

// MARK: - ChainTransactionStateFetchable

extension CardanoService: ChainTransactionStateFetchable {
    public func transactionState(for request: TransactionStateRequest) async throws -> TransactionChanges {
        let transaction = try await transaction(hash: request.id)
        
        return TransactionChanges(
            state: .confirmed,
            changes: [
                .networkFee(BigInt(stringLiteral: transaction.fee)),
                .blockNumber(transaction.block.number.asInt)
            ]
        )
    }
}

// MARK: - ChainSyncable

extension CardanoService: ChainSyncable {
    public func getInSync() async throws -> Bool {
        //TODO: Add getInSync check later
        true
    }
}

// MARK: - ChainStakable

extension CardanoService: ChainStakable {
    public func getValidators(apr: Double) async throws -> [DelegationValidator] {
        return []
    }

    public func getStakeDelegations(address: String) async throws -> [DelegationBase] {
        fatalError()
    }
}

// MARK: - ChainTokenable

extension CardanoService: ChainTokenable {
    public func getTokenData(tokenId: String) async throws -> Asset {
        fatalError()
    }
    
    public func getIsTokenAddress(tokenId: String) -> Bool {
        return false
    }
}

// MARK: - ChainIDFetchable
 
extension CardanoService: ChainIDFetchable {
    public func getChainID() async throws -> String {
        try await networkMagic().description
    }
}

// MARK: - ChainLatestBlockFetchable

extension CardanoService: ChainLatestBlockFetchable {
    public func getLatestBlock() async throws -> BigInt {
        try await latestBlock()
    }
}

// MARK: - ChainAddressStatusFetchable

extension CardanoService: ChainAddressStatusFetchable {
    public func getAddressStatus(address: String) async throws -> [AddressStatus] {
        []
    }
}
