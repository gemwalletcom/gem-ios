import BigInt
import Foundation
import Primitives

public typealias ChainServiceable =
    ChainAddressStatusFetchable &
    ChainBalanceable &
    ChainBroadcastable &
    ChainFeeRateFetchable &
    ChainIDFetchable &
    ChainLatestBlockFetchable &
    ChainStakable &
    ChainTokenable &
    ChainTransactionDataLoadable &
    ChainTransactionPreloadable &
    ChainTransactionStateFetchable

// MARK: - Protocols

public protocol ChainBalanceable: Sendable {
    func coinBalance(for address: String) async throws -> AssetBalance
    func tokenBalance(for address: String, tokenIds: [AssetId]) async throws -> [AssetBalance]
    func getStakeBalance(for address: String) async throws -> AssetBalance?
}

public protocol ChainFeeRateFetchable: Sendable {
    func feeRates(type: TransferDataType) async throws -> [FeeRate]
    func defaultPriority(for type: TransferDataType) -> FeePriority
}

public protocol ChainTransactionPreloadable: Sendable {
    func preload(input: TransactionPreloadInput) async throws -> TransactionLoadMetadata
}

public protocol ChainTransactionDataLoadable: Sendable {
    func load(input: TransactionInput) async throws -> TransactionData
}

public protocol ChainBroadcastable: Sendable {
    func broadcast(data: String, options: BroadcastOptions) async throws -> String
}

public struct TransactionStateRequest: Sendable {
    public let id: String
    public let senderAddress: String
    public let recipientAddress: String
    public let block: Int
    public let createdAt: Date

    public init(
        id: String,
        senderAddress: String,
        recipientAddress: String,
        block: Int,
        createdAt: Date
    ) {
        self.id = id
        self.senderAddress = senderAddress
        self.recipientAddress = recipientAddress
        self.block = block
        self.createdAt = createdAt
    }
}

public protocol ChainTransactionStateFetchable: Sendable {
    func transactionState(for request: TransactionStateRequest) async throws -> TransactionChanges
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
    func getIsTokenAddress(tokenId: String) async throws -> Bool
}

public protocol ChainLatestBlockFetchable: Sendable {
    func getLatestBlock() async throws -> BigInt
}

public protocol ChainAddressStatusFetchable: Sendable {
    func getAddressStatus(address: String) async throws -> [AddressStatus]
}

public protocol ChainFeePriorityPreference: Sendable {}

public extension ChainFeeRateFetchable {
    func defaultPriority(for type: TransferDataType) -> FeePriority {
        switch type {
        case .swap(let fromAsset, _, _): fromAsset.chain == .bitcoin ? .fast : .normal
        case .tokenApprove, .stake, .transfer, .deposit, .transferNft, .generic, .account, .perpetual, .withdrawal: .normal
        }
    }
}

public extension ChainStakable {
    func getValidators(apr: Double) async throws -> [DelegationValidator] {
        return []
    }

    func getStakeDelegations(address: String) async throws -> [DelegationBase] {
        return []
    }
}

public extension ChainTokenable {
    func getTokenData(tokenId: String) async throws -> Asset {
        throw AnyError("Not Implemented")
    }
    
    func getIsTokenAddress(tokenId: String) -> Bool {
        return false
    }
}

public extension ChainAddressStatusFetchable {
    func getAddressStatus(address: String) async throws -> [AddressStatus] {
        return []
    }
}

