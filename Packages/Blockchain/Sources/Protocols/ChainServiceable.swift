import Foundation
import Primitives
import BigInt

public typealias ChainServiceable = ChainBalanceable &
    ChainBroadcastable &
    ChainTransactionPreloadable &
    ChainFeeRateFetchable &
    ChainTransactionStateFetchable &
    ChainSyncable &
    ChainStakable &
    ChainTokenable &
    ChainIDFetchable &
    ChainLatestBlockFetchable &
    ChainAddressStatusFetchable

// MARK: - Protocols

public protocol ChainBalanceable: Sendable {
    func coinBalance(for address: String) async throws -> AssetBalance
    func tokenBalance(for address: String, tokenIds: [AssetId]) async throws -> [AssetBalance]
    func getStakeBalance(for address: String) async throws -> AssetBalance?
}

public protocol ChainFeeRateFetchable: Sendable {
    func feeRates(type: TransferDataType) async throws -> [FeeRate]
}

public protocol ChainTransactionPreloadable: Sendable  {
    func load(input: TransactionInput) async throws -> TransactionPreload
}

public protocol ChainBroadcastable: Sendable {
    func broadcast(data: String, options: BroadcastOptions) async throws -> String
}

public struct TransactionStateRequest: Sendable {
    public let id: String
    public let senderAddress: String
    public let recipientAddress: String
    public let block: String
    
    public init(
        id: String,
        senderAddress: String,
        recipientAddress: String,
        block: String
    ) {
        self.id = id
        self.senderAddress = senderAddress
        self.recipientAddress = recipientAddress
        self.block = block
    }
}

public protocol ChainTransactionStateFetchable: Sendable {
    func transactionState(for request: TransactionStateRequest) async throws -> TransactionChanges
}

public protocol ChainSyncable: Sendable {
    func getInSync() async throws -> Bool
}

public protocol ChainIDFetchable: Sendable {
    func getChainID() async throws -> String
}

public protocol ChainStakable: Sendable {
    func getValidators(apr: Double) async throws -> [DelegationValidator]
    func getStakeDelegations(address: String) async throws -> [DelegationBase]
}

public protocol ChainTokenable: Sendable {
    func getTokenData(tokenId: String) async throws -> Asset
    func getIsTokenAddress(tokenId: String) -> Bool
}

public protocol ChainLatestBlockFetchable: Sendable {
    func getLatestBlock() async throws -> BigInt
}

public protocol ChainAddressStatusFetchable: Sendable {
    func getAddressStatus(address: String) async throws -> [AddressStatus]
}
