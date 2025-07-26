// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import BigInt
import func Gemstone.tonEncodeGetWalletAddress
import func Gemstone.tonDecodeJettonAddress

public struct TonService: Sendable {
    
    let chain: Chain
    let provider: Provider<TonProvider>
    
    private let baseFee = BigInt(10_000_000) // 0.01 TON
    private let jettonTokenAccountCreation = BigInt(300_000_000) // 0.3 TON

    public init(
        chain: Chain,
        provider: Provider<TonProvider>
    ) {
        self.chain = chain
        self.provider = provider
    }
}

// MARK: - Business Logic

extension TonService {
    private func walletInformation(address: String) async throws -> TonWalletInfo {
        return try await provider
            .request(.walletInformation(address: address))
            .map(as: TonResult<TonWalletInfo>.self).result
    }

    private func tokenBalance(address: String) async throws -> BigInt {
        let balance = try await provider
            .request(.tokenData(id: address))
            .map(as: TonResult<TonJettonBalance>.self).result.balance
        return BigInt(balance)
    }

    private func addressState(address: String) async throws -> Bool {
        try await provider
            .request(.addressState(address: address))
            .map(as: TonResult<String>.self).result == "active"
    }

    private func jettonAddress(tokenId: String, address: String) async throws -> String {
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
    
    private func masterChainInfo() async throws -> TonMasterChainBlock {
        try await provider
            .request(.masterChainInfo)
            .map(as: TonResult<TonMasterChainBlock>.self).result
    }
    
    private func fee(input: FeeInput) async throws -> Fee {
        switch input.type {
        case .transfer(let asset), .deposit(let asset):
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
                    case false: jettonTokenAccountCreation
                }
                return Fee(
                    fee: baseFee + jettonAccountFee,
                    gasPriceType: .regular(gasPrice: baseFee),
                    gasLimit: 1,
                    options: [.tokenAccountCreation: BigInt(jettonAccountFee)]
                )
            }
        case .swap:
            let fee = baseFee + jettonTokenAccountCreation
            return Fee(
                fee: fee,
                gasPriceType: .regular(gasPrice: baseFee),
                gasLimit: 1,
                options: [.tokenAccountCreation: jettonTokenAccountCreation]
            )
        case .transferNft, .tokenApprove, .generic, .stake, .account, .perpetual:
            fatalError()
        }
    }
}

// MARK: - ChainBalanceable

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

    public func getStakeBalance(for address: String) async throws -> AssetBalance? {
        .none
    }
}

extension TonService: ChainFeeRateFetchable {
    public func feeRates(type: TransferDataType) async throws -> [FeeRate] {
        FeeRate.defaultRates()
    }
}

extension TonService: ChainTransactionPreloadable {
    public func preload(input: TransactionPreloadInput) async throws -> TransactionPreload {
        .none
    }
}

// MARK: - ChainTransactionPreloadable

extension TonService: ChainTransactionDataLoadable {
    public func load(input: TransactionInput) async throws -> TransactionData {
        switch input.asset.id.type {
        case .native:
            async let getWallet = walletInformation(address: input.senderAddress)
            async let getFee = fee(input: input.feeInput);
            let (wallet, fee) = try await (getWallet, getFee)
            
            return TransactionData(
                sequence: wallet.sequence,
                fee: fee
            )
        case .token:
            async let getWallet = walletInformation(address: input.senderAddress)
            async let getJettonAddress = jettonAddress(tokenId: try input.asset.getTokenId(), address: input.senderAddress)
            async let getFee = fee(input: input.feeInput)
            let (wallet, jettonAddress, fee) = try await (getWallet, getJettonAddress, getFee)
            
            return TransactionData(
                sequence: wallet.sequence,
                token: SignerInputToken(senderTokenAddress: jettonAddress),
                fee: fee
            )
        }
    }
}

// MARK: - ChainBroadcastable

extension TonService: ChainBroadcastable {
    public func broadcast(data: String, options: BroadcastOptions) async throws -> String {
        let result = try await provider
            .request(.broadcast(data: data))
            .map(as: TonResult<TonBroadcastTransaction>.self).result

        guard let hash = Data(base64Encoded: result.hash) else {
            throw AnyError("Invalid transaction hash")
        }
        return hash.hexString
    }
}

// MARK: - ChainTransactionStateFetchable

extension TonService: ChainTransactionStateFetchable {
    public func transactionState(for request: TransactionStateRequest) async throws -> TransactionChanges {
        let transactions = try await provider
            .request(.transaction(hash: request.id))
            .map(as: TonMessageTransactions.self)
        
        guard let transaction = transactions.transactions.first else {
            throw AnyError("transaction not found")
        }
        let state: TransactionState = {
            if transaction.out_msgs.isEmpty {
                return .failed
            } else if let outMessage = transaction.out_msgs.first, outMessage.bounce && outMessage.bounced {
                return .failed
            }
            return .confirmed
        }()
        
        return TransactionChanges(
            state: state
        )
    }
}

// MARK: - ChainSyncable

extension TonService: ChainSyncable {
    public func getInSync() async throws -> Bool {
        //TODO: Add getInSync check later
        true
    }
}

// MARK: - ChainStakable

extension TonService: ChainStakable {
    public func getValidators(apr: Double) async throws -> [DelegationValidator] {
        return []
    }

    public func getStakeDelegations(address: String) async throws -> [DelegationBase] {
        fatalError()
    }
}

// MARK: - ChainTokenable

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
        try await masterChainInfo().initial.root_hash
    }
}

// MARK: - ChainLatestBlockFetchable

extension TonService: ChainLatestBlockFetchable {
    public func getLatestBlock() async throws -> BigInt {
        try await masterChainInfo().last.seqno.asInt.asBigInt
    }
}

// MARK: - Models

public struct TonMasterChainBlock: Codable, Sendable {
    public var last: TonBlock
    public var initial: TonBlock

    enum CodingKeys: String, CodingKey {
        case last
        case initial = "init"
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

// MARK: - ChainAddressStatusFetchable

extension TonService: ChainAddressStatusFetchable {
    public func getAddressStatus(address: String) async throws -> [AddressStatus] {
        []
    }
}
