// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import BigInt
import GemstonePrimitives
import WalletCore

public struct PolkadotService: Sendable {
    
    static let periodLength: UInt64 = 64
    
    let chain: Chain
    let provider: Provider<PolkadotProvider>
    
    public init(
        chain: Chain,
        provider: Provider<PolkadotProvider>
    ) {
        self.chain = chain
        self.provider = provider
    }
}

// MARK: - Business Logic

extension PolkadotService {
    private func balance(address: String) async throws -> PolkadotAccountBalance {
        try await provider
            .request(.balance(address: address))
            .map(as: PolkadotAccountBalance.self)
    }
    
    private func block(number: String) async throws -> PolkadotBlock {
        try await provider
            .request(.block(id: number))
            .map(as: PolkadotBlock.self)
    }
    
    private func blocks(from: String, to: String) async throws -> [PolkadotBlock] {
        try await provider
            .request(.blocks(range: "\(from)-\(to)"))
            .map(as: [PolkadotBlock].self)
    }
    
    private func blockHead() async throws -> PolkadotBlock {
        try await provider
            .request(.blockHead)
            .map(as: PolkadotBlock.self)
    }
    
    private func nodeVersion() async throws -> PolkadotNodeVersion {
        try await provider
            .request(.nodeVersion)
            .map(as: PolkadotNodeVersion.self)
    }
    
    private func transactionMaterial() async throws -> PolkadotTransactionMaterial {
        try await provider
            .request(.transactionMaterial)
            .map(as: PolkadotTransactionMaterial.self)
    }
    
    private func estimateFee(tx: String) async throws -> PolkadotEstimateFee {
        try await provider
            .request(.estimateFee(tx))
            .map(as: PolkadotEstimateFee.self)
    }
    
    private func transactionPayload(toAddress: String, value: BigInt, nonce: BigInt, data: SigningData.Polkadot) throws -> String {
        let input = PolkadotSigningInput.with {
            $0.genesisHash = data.genesisHash
            $0.blockHash = data.blockHash
            $0.nonce = nonce.asUInt
            $0.specVersion = data.specVersion
            $0.network = CoinType.polkadot.ss58Prefix
            $0.transactionVersion = data.transactionVersion
            $0.privateKey = PrivateKey().data
            $0.era = PolkadotEra.with {
                $0.blockNumber = data.blockNumber
                $0.period = data.period
            }
            $0.balanceCall.transfer = PolkadotBalance.Transfer.with {
                $0.toAddress = toAddress
                $0.value = value.magnitude.serialize()
            }
        }
        let output: PolkadotSigningOutput = AnySigner.sign(input: input, coin: .polkadot)
        return output.encoded.hexString.append0x
    }
}

// MARK: - ChainBalanceable

extension PolkadotService: ChainBalanceable {
    public func coinBalance(for address: String) async throws -> AssetBalance {
        let balance = try await balance(address: address)
        let free = BigInt(stringLiteral: balance.free)
        let reserved = BigInt(stringLiteral: balance.reserved)
        let available = max(free - reserved, .zero)

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

extension PolkadotService: ChainFeeRateFetchable {
    public func feeRates(type: TransferDataType) async throws -> [FeeRate] {
        return [
            FeeRate(priority: .normal, gasPriceType: .regular(gasPrice: 1))
        ]
    }
}

extension PolkadotService: ChainTransactionPreloadable {
    public func preload(input: TransactionPreloadInput) async throws -> TransactionPreload {
        .none
    }
}

// MARK: - ChainTransactionPreloadable

extension PolkadotService: ChainTransactionLoadable {
    public func load(input: TransactionInput) async throws -> TransactionLoad {
        async let getTransactionMaterial = try await transactionMaterial()
        async let getDestinationAccount = try await balance(address: input.destinationAddress)
        async let getNonce = BigInt(stringLiteral: balance(address: input.senderAddress).nonce)
        
        let (nonce, transactionMaterial, _) = try await (getNonce, getTransactionMaterial, getDestinationAccount)
        
        //TODO: Add check for min 1 DOT
        
        let transactionPayload = SigningData.Polkadot(
            genesisHash: try Data.from(hex: transactionMaterial.genesisHash),
            blockHash: try Data.from(hex: transactionMaterial.at.hash),
            blockNumber: try BigInt.from(string: transactionMaterial.at.height).asUInt,
            specVersion: try BigInt.from(string: transactionMaterial.specVersion).asUInt32,
            transactionVersion: try BigInt.from(string: transactionMaterial.txVersion).asUInt32,
            period: Self.periodLength
        )
        
        let transactionData = try self.transactionPayload(
            toAddress: input.destinationAddress,
            value: input.value,
            nonce: nonce,
            data: transactionPayload
        )
        let fee = try await BigInt(stringLiteral: estimateFee(tx: transactionData).partialFee)
        
        return TransactionLoad(
            sequence: nonce.asInt,
            data: .polkadot(transactionPayload), block: SignerInputBlock(number: Int(transactionMaterial.at.height)!),
            fee: Fee(fee: fee, gasPriceType: input.feeInput.gasPrice, gasLimit: 1)
        )
    }
}

// MARK: - ChainBroadcastable

extension PolkadotService: ChainBroadcastable {
    public func broadcast(data: String, options: BroadcastOptions) async throws -> String {
        try await provider
            .request(.broadcast(data: data))
            .mapOrError(as: PolkadotTransactionBroadcast.self, asError: PolkadotTransactionBroadcastError.self)
            .hash
    }
}

// MARK: - ChainTransactionStateFetchable

extension PolkadotService: ChainTransactionStateFetchable {
    public func transactionState(for request: TransactionStateRequest) async throws -> TransactionChanges {
        guard let blockNumber = Int(request.block), blockNumber > 0 else {
            throw AnyError("Invalid block number")
        }
        let blockHead = BigInt(stringLiteral: try await blockHead().number)
        let fromBlock = String(blockNumber)
        let toBlock = min(blockHead, BigInt(blockNumber+Int(Self.periodLength)))
        let blocks = try await blocks(from: fromBlock, to: toBlock.description)
        
        for block in blocks {
            for extrinsic in block.extrinsics {
                if extrinsic.hash == request.id {
                    let state: TransactionState = extrinsic.success ? .confirmed : .failed
                    return TransactionChanges(state: state)
                }
            }
        }
        
        return TransactionChanges(
            state: .pending,
            changes: [
                .blockNumber(blockNumber),
            ]
        )
    }
}

// MARK: - ChainSyncable

extension PolkadotService: ChainSyncable {
    public func getInSync() async throws -> Bool {
        //TODO: Add getInSync check later
        true
    }
}

// MARK: - ChainStakable

extension PolkadotService: ChainStakable {
    public func getValidators(apr: Double) async throws -> [DelegationValidator] {
        return []
    }

    public func getStakeDelegations(address: String) async throws -> [DelegationBase] {
        fatalError()
    }
}

// MARK: - ChainTokenable

extension PolkadotService: ChainTokenable {
    public func getTokenData(tokenId: String) async throws -> Asset {
        fatalError("unimplemented")
    }
    
    public func getIsTokenAddress(tokenId: String) -> Bool {
        return false
    }
}

// MARK: - ChainIDFetchable
 
extension PolkadotService: ChainIDFetchable {
    public func getChainID() async throws -> String {
        try await nodeVersion().chain
    }
}

// MARK: - ChainLatestBlockFetchable

extension PolkadotService: ChainLatestBlockFetchable {
    public func getLatestBlock() async throws -> BigInt {
        BigInt(stringLiteral: try await blockHead().number)
    }
}


// MARK: - ChainAddressStatusFetchable

extension PolkadotService: ChainAddressStatusFetchable {
    public func getAddressStatus(address: String) async throws -> [AddressStatus] {
        []
    }
}

extension PolkadotTransactionBroadcastError: LocalizedError {
    public var errorDescription: String? {
        cause
    }
}
