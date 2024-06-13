// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import BigInt
import Gemstone

public struct TonService {
    
    let chain: Chain
    let provider: Provider<TonProvider>
    
    private let baseFee = BigInt(10_000_000)
    
    public init(
        chain: Chain,
        provider: Provider<TonProvider>
    ) {
        self.chain = chain
        self.provider = provider
    }
    
    func walletInformation(address: String) async throws -> TonWalletInfo {
        return try await provider
            .request(.walletInformation(address: address))
            .map(as: TonResult<TonWalletInfo>.self).result
    }
    
    func tokenBalance(address: String) async throws -> BigInt {
        let balance = try await provider
            .request(.tokenData(id: address))
            .map(as: TonResult<TonJettonBalance>.self).result.balance
        return BigInt(balance)
    }
    
    func addressState(address: String) async throws -> Bool {
        try await provider
            .request(.addressState(address: address))
            .map(as: TonResult<String>.self).result == "active"
    }
    
    func jettonAddress(tokenId: String, address: String) async throws -> String {
        let data = try Gemstone.tonEncodeGetWalletAddress(address: address)
        let responce = try await provider
            .request(.runGetMethod(
                address: tokenId,
                method: "get_wallet_address", stack: [
                    "tvm.Slice",
                    data,
                ]
            ))
            .map(as: TonResult<RunGetMethod>.self).result
        
        guard
            let value = responce.stack.first?.last,
            case let .cell(cell) = value else {
            throw AnyError("invalid stack")
        }
        return try Gemstone.tonDecodeJettonAddress(base64Data: cell.object.data.b64, len: cell.object.data.len.asUInt64)
    }
}

extension TonService: ChainBalanceable {
    public func coinBalance(for address: String) async throws -> AssetBalance {
        let balance = try await provider
            .request(.balance(address: address))
            .map(as: TonResult<String>.self).result

        return Primitives.AssetBalance(
            assetId: chain.assetId,
            balance: Balance(available: BigInt(balance) ?? .zero)
        )
    }
    
    public func tokenBalance(for address: String, tokenIds: [AssetId]) async throws -> [AssetBalance] {
        var result: [AssetBalance] = []
        
        for tokenId in tokenIds {
            let jettonAddress = try await jettonAddress(tokenId: tokenId.tokenId ?? "", address: address)
            let state = try await addressState(address: jettonAddress)
            
            switch state {
            case true:
                let balance = try await tokenBalance(address: jettonAddress)
                result.append(Primitives.AssetBalance(
                    assetId: tokenId,
                    balance: Balance(available: balance)
                ))
            case false:
                result.append(Primitives.AssetBalance(
                    assetId: tokenId,
                    balance: Balance(available: .zero)
                ))
            }
        }
        
        return result
    }
}

extension TonService: ChainFeeCalculateable {
    public func fee(input: FeeInput) async throws -> Fee {
        switch input.type {
        case .transfer(let asset):
            
            switch asset.id.type {
            case .native:
                return Fee(
                    fee: baseFee,
                    gasPriceType: .regular(gasPrice: baseFee),
                    gasLimit: 1
                )
            case .token:
                let tokenId = try asset.getTokenId()
                let jettonAddress = try await jettonAddress(tokenId: tokenId, address: input.destinationAddress)
                let state = try await addressState(address: jettonAddress)

                // https://docs.ton.org/develop/smart-contracts/fees#fees-for-sending-jettons
                let jettonAccountFee: BigInt = switch state {
                    case true: input.memo == nil ? BigInt(100_000_000) : BigInt(60_000_000) // 0.06
                    case false: BigInt(300_000_000) // 0.3 TON
                }
                return Fee(
                    fee: baseFee,
                    gasPriceType: .regular(gasPrice: baseFee),
                    gasLimit: 1,
                    options: [.tokenAccountCreation: BigInt(jettonAccountFee)]
                )
            }
        case .swap, .generic, .stake:
            fatalError()
        }
    }
}

extension TonService: ChainTransactionPreloadable {
    public func load(input: TransactionInput) async throws -> TransactionPreload {
        switch input.asset.id.type {
        case .native:
            async let getWallet = walletInformation(address: input.senderAddress)
            async let getFee = fee(input: input.feeInput);
            let (wallet, fee) = try await (getWallet, getFee)
            
            return TransactionPreload(
                sequence: wallet.sequence,
                fee: fee
            )
        case .token:
            async let getWallet = walletInformation(address: input.senderAddress)
            async let getJettonAddress = jettonAddress(tokenId: try input.asset.getTokenId(), address: input.senderAddress)
            async let getFee = fee(input: input.feeInput)
            let (wallet, jettonAddress, fee) = try await (getWallet, getJettonAddress, getFee)
            
            return TransactionPreload(
                sequence: wallet.sequence,
                token: SignerInputToken(senderTokenAddress: jettonAddress),
                fee: fee
            )
        }
    }
}

extension TonService: ChainBroadcastable {
    public func broadcast(data: String, options: BroadcastOptions) async throws -> String {
        return try await provider
            .request(.broadcast(data: data))
            .map(as: TonResult<TonBroadcastTransaction>.self).result.hash
    }
}

extension TonService: ChainTransactionStateFetchable {
    public func transactionState(for id: String, senderAddress: String) async throws -> TransactionChanges {
        guard let data = Data(base64Encoded: id) else {
            throw AnyError("Invalid transaction id")
        }
        let transactions = try await provider
            .request(.transaction(hash: data.hexString))
            .map(as: [TonTransactionMessage].self)
        
        guard
            let transaction = transactions.first,
            let newTransactionId = Data(base64Encoded: transaction.hash)?.hexString else {
            throw AnyError("transaction not found")
        }
        
        return TransactionChanges(
            state: .confirmed,
            changes: [
                .hashChange(old: id, new: newTransactionId)
            ]
        )
    }
}

extension TonService: ChainSyncable {
    public func getInSync() async throws -> Bool {
        fatalError()
    }
}

extension TonService: ChainStakable {
    public func getValidators(apr: Double) async throws -> [DelegationValidator] {
        return []
    }

    public func getStakeDelegations(address: String) async throws -> [DelegationBase] {
        fatalError()
    }
}

extension TonService: ChainTokenable {
    public func getTokenData(tokenId: String) async throws -> Asset {
        let token = try await provider
            .request(.tokenData(id: tokenId))
            .map(as: TonResult<TonJettonToken>.self).result
        
        let assetId = AssetId(chain: chain, tokenId: tokenId)
        
        let data = token.jetton_content.data
        let decimals = Int(data.decimals)?.asInt32 ?? 0

        return Asset(
            id: assetId,
            name: data.name,
            symbol: data.symbol,
            decimals: decimals,
            type: .jetton
        )
    }
    
    public func getIsTokenAddress(tokenId: String) -> Bool {
        tokenId.hasPrefix("EQ") && tokenId.count.isBetween(40, and: 60)
    }
}

// MARK: - ChainIDFetchable
 
extension TonService: ChainIDFetchable {
    public func getChainID() async throws -> String {
        fatalError()
    }
}

struct RunGetMethod: Codable {
    let stack: [[StackItem]]
}

// Define an enum to handle mixed types within the stack arrays
enum StackItem: Codable {
    case string(String)
    case cell(Cell)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            self = .string(string)
            return
        }
        if let cell = try? container.decode(Cell.self) {
            self = .cell(cell)
            return
        }
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unexpected type")
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let string):
            try container.encode(string)
        case .cell(let cell):
            try container.encode(cell)
        }
    }
}

// Define the structure for "cell" dictionary
struct Cell: Codable {
    let bytes: String
    let object: Object
}

// Define the structure for the "object" dictionary
struct Object: Codable {
    let data: DataClass
    let refs: [String] // Assuming `refs` is an array of strings
    let special: Bool
}

// Define the structure for the "data" dictionary
struct DataClass: Codable {
    let b64: String
    let len: Int
}

extension TonWalletInfo {
    var sequence: Int {
        Int(seqno ?? 0)
    }
}
