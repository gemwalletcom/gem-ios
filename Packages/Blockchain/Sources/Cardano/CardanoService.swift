// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import BigInt
import GemstonePrimitives
import WalletCore

public struct CardanoService: Sendable {
    
    let chain: Chain
    let provider: Provider<CardanoProvider>
    
    public init(
        chain: Chain,
        provider: Provider<CardanoProvider>
    ) {
        self.chain = chain
        self.provider = provider
    }
}

// MARK: - Business Logic

extension CardanoService {
    private func utxos(address: String) async throws -> [UTXO] {
        try await provider
            .request(.utxos(address: address))
            .map(as: JSONRPCResponse<[CardanoUTXO]>.self).result
            .map {
                UTXO(
                    transaction_id: $0.transaction.id,
                    vout: $0.index,
                    value: String($0.value.ada.lovelace),
                    address: $0.address
                )
            }
    }
    
    
    private func latestBlock() async throws -> BigInt {
        try await provider
            .request(.latestBlock)
            .map(as: JSONRPCResponse<CardanoBlockTip>.self).result.slot.asBigInt
    }
    
    private func genesisConfiguration() async throws -> CardanoGenesisConfiguration {
        try await provider
            .request(.genesisConfiguration)
            .map(as: JSONRPCResponse<CardanoGenesisConfiguration>.self).result
    }
    
    private func calculateFee(input: TransactionInput, utxos: [UTXO]) throws -> BigInt {
        let signingInput = try CardanoSigningInput.with {
            $0.utxos = try utxos.map { utxo in
                try CardanoTxInput.with {
                    $0.outPoint.txHash = try Data.from(hex: utxo.transaction_id)
                    $0.outPoint.outputIndex = UInt64(utxo.vout)
                    $0.address = try utxo.address.unwrapOrThrow()
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
        let utxos = try await utxos(address: address)
        let available = utxos.map { BigInt(stringLiteral: $0.value) }.reduce(BigInt(0), +)
        
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
        //let fee = try await genesisConfiguration()
        //let minFee = BigInt(fee.updatableParameters.minFeeConstant.ada.lovelace)
        
        return [
            FeeRate(priority: .normal, gasPriceType: .regular(gasPrice: 1)),
        ]
    }
}

// MARK: - ChainTransactionPreloadable

extension CardanoService: ChainTransactionPreloadable {
    public func load(input: TransactionInput) async throws -> TransactionPreload {
        let utxos = try await utxos(address: input.senderAddress)
        let fee = try calculateFee(input: input, utxos: utxos)
        
        return TransactionPreload(
            fee: Fee(fee: fee, gasPriceType: .regular(gasPrice: 1), gasLimit: 1),
            utxos: utxos
        )
    }
}

// MARK: - ChainBroadcastable

extension CardanoService: ChainBroadcastable {
    public func broadcast(data: String, options: BroadcastOptions) async throws -> String {
        try await provider
            .request(.broadcast(data: data))
            .mapOrError(
                as: JSONRPCResponse<CardanoTransactionBroadcast>.self,
                asError: JSONRPCError.self
            ).result.transaction.id
    }
}

// MARK: - ChainTransactionStateFetchable

extension CardanoService: ChainTransactionStateFetchable {
    public func transactionState(for request: TransactionStateRequest) async throws -> TransactionChanges {
        let utxos = try await utxos(address: request.recipientAddress)
        //Checking received utxo on the recipient. TODO: Look for better ways
        let state: TransactionState = utxos.contains { $0.transaction_id == request.id } ? .confirmed : .pending
        
        return TransactionChanges(state: state)
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
        String(try await genesisConfiguration().updatableParameters.networkMagic)
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
