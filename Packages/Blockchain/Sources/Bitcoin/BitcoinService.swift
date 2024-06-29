// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import BigInt
import WalletCore
import WalletCorePrimitives

public struct BitcoinService {
    
    let chain: BitcoinChain
    let provider: Provider<BitcoinProvider>
    
    public init(
        chain: BitcoinChain,
        provider: Provider<BitcoinProvider>
    ) {
        self.chain = chain
        self.provider = provider
    }
}

// MARK: - Business Logic

extension BitcoinService {
    private func fee() async throws  -> BigInt {
        let fee = try await provider
            .request(.fee(priority: chain.defaultFeePriority))
            .map(as: BitcoinFeeResult.self)
        let byteFee = try BigInt.from(fee.result, decimals: Int(chain.chain.asset.decimals))

        return byteFee
    }

    private func utxo(address: String) async throws -> [UTXO] {
        return try await provider
            .request(.utxo(address: address))
            .map(as: [BitcoinUTXO].self)
            .map { $0.mapToUTXO() }
    }

    private func calculateFee(byteFee: BigInt, feeInput: FeeInput, utxos: [UTXO]) async throws -> Fee {
        let coinType = chain.chain.coinType
        let gasPrice = max(byteFee.int / 1000, chain.minimumByteFee)
        let utxo = utxos.map {
            $0.mapToUnspendTransaction(address: feeInput.senderAddress, coinType: coinType)
        }

        let input = BitcoinSigningInput.with {
            $0.coinType = coinType.rawValue
            $0.hashType = BitcoinScript.hashTypeForCoin(coinType: coinType)
            $0.amount = feeInput.value.int64
            $0.byteFee = Int64(gasPrice)
            $0.toAddress = feeInput.destinationAddress
            $0.changeAddress = feeInput.senderAddress
            $0.utxo = utxo
            $0.scripts = utxo.mapToScripts(address: feeInput.senderAddress, coinType: coinType)
            $0.useMaxAmount = feeInput.isMaxAmount
        }

        let plan: BitcoinTransactionPlan = AnySigner.plan(input: input, coin: coinType)

        if plan.error != CommonSigningError.ok {
            throw AnyError("unable to estimate byte fee")
        }

        return Fee(
            fee: BigInt(plan.fee),
            gasPriceType: .regular(gasPrice: BigInt(gasPrice)),
            gasLimit: 1
        )
    }
}

// MARK: - ChainBalanceable

extension BitcoinService: ChainBalanceable {
    public func coinBalance(for address: String) async throws -> AssetBalance {
        let account = try await provider
            .request(.balance(address: address))
            .map(as: BitcoinAccount.self)
        
        return Primitives.AssetBalance(
            assetId: chain.chain.assetId,
            balance: Balance(available: BigInt(stringLiteral: account.balance))
        )
    }
    
    public func tokenBalance(for address: String, tokenIds: [AssetId]) async throws -> [AssetBalance] {
        return []
    }

    public func getStakeBalance(address: String) async throws -> AssetBalance {
        fatalError()
    }
}

// MARK: - ChainFeeCalculateable

extension BitcoinService: ChainFeeCalculateable {
    public func fee(input: FeeInput) async throws -> Fee {
        let utxos = try await utxo(address: input.senderAddress)
        let byteFee = try await fee()
        return try await calculateFee(byteFee: byteFee, feeInput: input, utxos: utxos)
    }
}

// MARK: - ChainTransactionPreloadable

extension BitcoinService: ChainTransactionPreloadable {
    public func load(input: TransactionInput) async throws -> TransactionPreload {
        async let getUtxos = utxo(address: input.senderAddress)
        async let getByteFee = fee()
        let (utxos, byteFee) = try await (getUtxos, getByteFee)
        let fee = try await calculateFee(byteFee: byteFee, feeInput: input.feeInput, utxos: utxos)
        
        return TransactionPreload(
            fee: fee,
            utxos: utxos
        )
    }
}

// MARK: - ChainBroadcastable

extension BitcoinService: ChainBroadcastable {
    public func broadcast(data: String, options: BroadcastOptions) async throws -> String {
        let result = try await provider
            .request(.broadcast(data: data))
            .map(as: BitcoinTransactionBroacastResult.self)
        
        if let error = result.error {
            throw AnyError(error.message)
        }
        guard let hash = result.result else {
            throw AnyError("unknown hash")
        }
        
        return hash
    }
}

// MARK: - ChainTransactionStateFetchable

extension BitcoinService: ChainTransactionStateFetchable {
    public func transactionState(for id: String, senderAddress: String) async throws -> TransactionChanges {
        let transaction = try await provider
            .request(.transaction(id: id))
            .map(as: BitcoinTransaction.self)
        return TransactionChanges(
            state: transaction.blockHeight > 0 ? .confirmed : .pending
        )
    }
}

// MARK: - ChainSyncable

extension BitcoinService: ChainSyncable {
    public func getInSync() async throws -> Bool {
        return try await provider
            .request(.nodeInfo)
            .map(as: BitcoinNodeInfo.self).blockbook.inSync
    }
}

// MARK: - ChainStakable

extension BitcoinService: ChainStakable {
    public func getValidators(apr: Double) async throws -> [DelegationValidator] {
        return []
    }

    public func getStakeDelegations(address: String) async throws -> [DelegationBase] {
        fatalError()
    }
}

// MARK: - ChainTokenable

extension BitcoinService: ChainTokenable {
    public func getTokenData(tokenId: String) async throws -> Asset {
        throw AnyError("Not Implemented")
    }
    
    public func getIsTokenAddress(tokenId: String) -> Bool {
        false
    }
}

// MARK: - ChainIDFetchable
 
extension BitcoinService: ChainIDFetchable {
    public func getChainID() async throws -> String? {
        throw AnyError("Not Implemented")
    }
}

// MARK: - ChainLatestBlockFetchable

extension BitcoinService: ChainLatestBlockFetchable {
    public func getLatestBlock() async throws -> BigInt {
        throw AnyError("Not Implemented")
    }
}

// MARK: - Models extensions

public extension UTXO {
    func mapToUnspendTransaction(address: String, coinType: CoinType) -> BitcoinUnspentTransaction {
        BitcoinUnspentTransaction.with {
            $0.outPoint.hash = Data.reverse(hexString: transaction_id)
            $0.outPoint.index = UInt32(vout)
            $0.amount = Int64(value)!
            $0.script = BitcoinScript.lockScriptForAddress(address: address, coin: coinType).data
        }
    }
}

public extension Array where Element == BitcoinUnspentTransaction {
    func mapToScripts(address: String, coinType: CoinType) -> [String : Data] {
        return reduce(into: [String: Data]()) { map, data in
            let script = BitcoinScript.lockScriptForAddress(address: address, coin: coinType)
            
            guard coinType != .bitcoin, !script.data.isEmpty else {
                return
            }
            if let scriptHash = script.matchPayToScriptHash() {
                map[scriptHash.hexString] = script.matchPayToWitnessPublicKeyHash()
            } else if let scriptHash = script.matchPayToWitnessPublicKeyHash() {
                map[scriptHash.hexString] = script.matchPayToPubkeyHash()
            }
       }
    }
}
