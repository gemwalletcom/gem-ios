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
    let gateway: GatewayService
    
    public init(
        chain: Chain,
        provider: Provider<PolkadotProvider>,
        gateway: GatewayService
    ) {
        self.chain = chain
        self.provider = provider
        self.gateway = gateway
    }
}

// MARK: - Business Logic

extension PolkadotService {
    private func balance(address: String) async throws -> PolkadotAccountBalance {
        try await provider
            .request(.balance(address: address))
            .map(as: PolkadotAccountBalance.self)
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
        try await gateway.coinBalance(chain: chain, address: address)
    }
    
    public func tokenBalance(for address: String, tokenIds: [AssetId]) async throws -> [AssetBalance] {
        try await gateway.tokenBalance(chain: chain, address: address, tokenIds: tokenIds)
    }

    public func getStakeBalance(for address: String) async throws -> AssetBalance? {
        try await gateway.getStakeBalance(chain: chain, address: address)
    }
}

extension PolkadotService: ChainFeeRateFetchable {
    public func feeRates(type: TransferDataType) async throws -> [FeeRate] {
        try await gateway.feePriorityRates(chain: chain).map {
            FeeRate(priority: $0.priority, gasPriceType: .regular(gasPrice: $0.value))
        }
    }
}

extension PolkadotService: ChainTransactionPreloadable {
    public func preload(input: TransactionPreloadInput) async throws -> TransactionPreload {
        try await gateway.transactionPreload(chain: chain, input: input)
    }
}

// MARK: - ChainTransactionPreloadable

extension PolkadotService: ChainTransactionDataLoadable {
    public func load(input: TransactionInput) async throws -> TransactionData {
        async let getTransactionMaterial = try await transactionMaterial()
        async let getDestinationAccount = try await balance(address: input.destinationAddress)
        async let getNonce = BigInt(stringLiteral: balance(address: input.senderAddress).nonce)
        
        let (nonce, transactionMaterial, _) = try await (getNonce, getTransactionMaterial, getDestinationAccount)
        
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
        
        return TransactionData(
            sequence: nonce.asInt,
            data: .polkadot(transactionPayload), block: SignerInputBlock(number: Int(transactionMaterial.at.height)!),
            fee: Fee(fee: fee, gasPriceType: input.feeInput.gasPrice, gasLimit: 1)
        )
    }
}

// MARK: - ChainBroadcastable

extension PolkadotService: ChainBroadcastable {
    public func broadcast(data: String, options: BroadcastOptions) async throws -> String {
        try await gateway.transactionBroadcast(chain: chain, data: data)
    }
}

// MARK: - ChainTransactionStateFetchable

extension PolkadotService: ChainTransactionStateFetchable {
    public func transactionState(for request: TransactionStateRequest) async throws -> TransactionChanges {
        try await gateway.transactionStatus(chain: chain, request: request)
    }
}

// MARK: - ChainStakable

extension PolkadotService: ChainStakable {
    public func getValidators(apr: Double) async throws -> [DelegationValidator] {
        try await gateway.validators(chain: chain)
    }

    public func getStakeDelegations(address: String) async throws -> [DelegationBase] {
        try await gateway.delegations(chain: chain, address: address)
    }
}

// MARK: - ChainIDFetchable
 
extension PolkadotService: ChainIDFetchable {
    public func getChainID() async throws -> String {
        try await gateway.chainId(chain: chain)
    }
}

// MARK: - ChainLatestBlockFetchable

extension PolkadotService: ChainLatestBlockFetchable {
    public func getLatestBlock() async throws -> BigInt {
        try await gateway.latestBlock(chain: chain)
    }
}

extension PolkadotService: ChainTokenable, ChainAddressStatusFetchable { }
