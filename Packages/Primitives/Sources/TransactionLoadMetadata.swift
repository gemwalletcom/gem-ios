// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum TransactionLoadMetadata: Sendable {
    case none
    case solana(
        senderTokenAddress: String?,
        recipientTokenAddress: String?,
        tokenProgram: SolanaTokenProgramId?,
        blockHash: String
    )
    case ton(
        jettonWalletAddress: String?,
        sequence: Int64
    )
    case cosmos(
        accountNumber: Int64,
        sequence: Int64,
        chainId: String
    )
    case bitcoin(utxos: [UTXO])
    case cardano(utxos: [UTXO])
    case evm(nonce: Int64, chainId: Int64)
    case near(
        sequence: Int64,
        blockHash: String,
        isDestinationAddressExist: Bool
    )
    case stellar(sequence: Int64, isDestinationAddressExist: Bool)
    case xrp(sequence: Int64)
    case algorand(sequence: Int64)
    case aptos(sequence: Int64)
    case polkadot(
        sequence: Int64,
        genesisHash: String,
        blockHash: String,
        blockNumber: Int64,
        specVersion: UInt64,
        transactionVersion: UInt64,
        period: Int64
    )
    case tron(
        blockNumber: Int64,
        blockVersion: Int64,
        blockTimestamp: Int64,
        transactionTreeRoot: String,
        parentHash: String,
        witnessAddress: String
    )
}

extension TransactionLoadMetadata {
    public func getSequence() throws -> Int64 {
        switch self {
        case .ton(_, let sequence),
             .cosmos(_, let sequence, _),
             .near(let sequence, _, _),
             .stellar(let sequence, _),
             .xrp(let sequence),
             .algorand(let sequence),
             .aptos(let sequence),
             .polkadot(let sequence, _, _, _, _, _, _),
             .evm(let sequence, _):
            return sequence
        case .none, .bitcoin, .cardano, .tron, .solana:
            throw AnyError("Sequence not available for this metadata type")
        }
    }
    
    public func getBlockNumber() throws -> Int64 {
        switch self {
        case .polkadot(_, _, _, let blockNumber, _, _, _),
             .tron(let blockNumber, _, _, _, _, _):
            return blockNumber
        default:
            throw AnyError("Block number not available for this metadata type")
        }
    }
    
    public func getBlockHash() throws -> String {
        switch self {
        case .solana(_, _, _, let blockHash),
            .near(_, let blockHash, _),
             .polkadot(_, _, let blockHash, _, _, _, _):
            return blockHash
        default:
            throw AnyError("Block hash not available for this metadata type")
        }
    }
    
    public func getChainId() throws -> String {
        switch self {
        case .cosmos(_, _, let chainId):
            return chainId
        case .evm(_, let chainId):
            return String(chainId)
        default:
            throw AnyError("Chain ID not available for this metadata type")
        }
    }
    
    public func getUtxos() throws -> [UTXO] {
        switch self {
        case .bitcoin(let utxos),
             .cardano(let utxos):
            return utxos
        default:
            throw AnyError("UTXOs not available for this metadata type")
        }
    }
    
    public func getIsDestinationAddressExist() throws -> Bool {
        switch self {
        case .near(_, _, let isDestinationAddressExist),
             .stellar(_, let isDestinationAddressExist):
            return isDestinationAddressExist
        default:
            throw AnyError("Destination existence flag not available for this metadata type")
        }
    }
}
