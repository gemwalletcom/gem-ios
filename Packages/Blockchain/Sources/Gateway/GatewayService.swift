// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives
import BigInt
import NativeProviderService

public struct GatewayService: Sendable {
    let gateway: GemGateway
    
    public init(
        provider: NativeProvider
    ) {
        self.gateway = GemGateway(provider: provider)
    }
}

// MARK: - Balances

extension GatewayService {
    public func coinBalance(chain: Primitives.Chain, address: String) async throws -> AssetBalance {
        try await gateway.getBalanceCoin(chain: chain.rawValue, address: address).map()
    }

    public func tokenBalance(chain: Primitives.Chain, address: String, tokenIds: [Primitives.AssetId]) async throws -> [AssetBalance] {
        try await gateway.getBalanceTokens(chain: chain.rawValue, address: address, tokenIds: tokenIds.map(\.id)).map {
            try $0.map()
        }
    }

    public func getStakeBalance(chain: Primitives.Chain, address: String) async throws -> AssetBalance? {
        try await gateway.getBalanceStaking(chain: chain.rawValue, address: address)?.map()
    }
}

// MARK: - Transactions

extension GatewayService {
    public func transactionBroadcast(chain: Primitives.Chain, data: String) async throws -> String {
        try await gateway.transactionBroadcast(chain: chain.rawValue, data: data)
    }
    
    public func transactionStatus(chain: Primitives.Chain, request: TransactionStateRequest) async throws -> TransactionChanges {
        let update = try await gateway.getTransactionStatus(chain: chain.rawValue, request: request.map())
        let changes: [TransactionChange] = update.changes.compactMap {
            do {
                switch $0 {
                case .hashChange(old: let old, new: let new):
                    return TransactionChange.hashChange(old: old, new: new)
                case .metadata(let metadata):
                    return TransactionChange.metadata(metadata.map())
                case .blockNumber(let number):
                    return TransactionChange.blockNumber(try Int.from(string: number))
                case .networkFee(let fee):
                    return TransactionChange.networkFee(try BigInt.from(string: fee))
                }
            } catch {
                return nil
            }
        }
        return TransactionChanges(
            state: try TransactionState(id: update.state),
            changes: changes
        )
    }
}

// MARK: - Account

extension GatewayService {
    public func utxos(chain: Primitives.Chain, address: String) async throws -> [UTXO] {
        try await gateway.getUtxos(chain: chain.rawValue, address: address).map {
            try $0.map()
        }
    }
}

// TransactionPreload

// MARK: - State

extension GatewayService {
    public func chainId(chain: Primitives.Chain) async throws -> String {
        try await gateway.getChainId(chain: chain.rawValue)
    }
    
    public func latestBlock(chain: Primitives.Chain) async throws -> BigInt {
        let block = try await gateway.getBlockNumber(chain: chain.rawValue)
        return BigInt(block)
    }
    
    public func fees(chain: Primitives.Chain) async throws -> [FeePriorityValue] {
        try await gateway.getFees(chain: chain.rawValue).map { try $0.map() }
    }
}

// MARK: - Staking

extension GatewayService {
    public func validators(chain: Primitives.Chain) async throws -> [DelegationValidator] {
        do {
            let validators = try await gateway.getStakingValidators(chain: chain.rawValue)
                .map { try $0.map() }
            NSLog("validators \(validators)")
            return validators
        } catch {
            NSLog("validators \(error)")
            throw AnyError(error.localizedDescription)
        }
    }

    public func delegations(chain: Primitives.Chain, address: String) async throws -> [DelegationBase] {
        do {
            let delegations = try await gateway.getStakingDelegations(chain: chain.rawValue, address: address)
                .map { try $0.map() }
            NSLog("delegations \(delegations)")
            return delegations
        } catch {
            NSLog("delegations \(error)")
            throw AnyError(error.localizedDescription)
        }
    }
}

extension GemAssetBalance {
    func map() throws -> AssetBalance {
        AssetBalance(
            assetId: try AssetId(id: assetId),
            balance: try balance.map()
        )
    }
}

extension GemBalance {
    func map() throws -> Balance {
        Balance(
            available: try BigInt.from(string: available),
            frozen: try BigInt.from(string: frozen),
            locked: try BigInt.from(string: locked),
            staked: try BigInt.from(string: staked),
            pending: try BigInt.from(string: pending),
            rewards: try BigInt.from(string: rewards),
            reserved: try BigInt.from(string: reserved),
            withdrawable: try BigInt.from(string: withdrawable)
        )
    }
}

extension GemDelegationValidator {
    func map() throws -> DelegationValidator {
        DelegationValidator(
            chain: .hyperCore, // TODO: Pass chain context from gateway call
            id: id,
            name: name,
            isActive: isActive,
            commision: commission,
            apr: apr
        )
    }
}

extension GemDelegationBase {
    func map() throws -> DelegationBase {
        DelegationBase(
            assetId: AssetId(chain: .hyperCore, tokenId: nil), // TODO: Pass asset context from gateway call
            state: try DelegationState(id: delegationState),
            balance: balance,
            shares: "0", // TODO: Add shares field to GemDelegationBase
            rewards: rewards,
            completionDate: completionDate.map { Date(timeIntervalSince1970: TimeInterval($0)) },
            delegationId: delegationId,
            validatorId: validatorId
        )
    }
}

extension GemUtxo {
    func map() throws -> UTXO {
        UTXO(
            transaction_id: transactionId,
            vout: Int32(vout),
            value: value,
            address: "" // TODO: Add address field to GemUtxo
        )
    }
}

extension GemFeePriorityValue {
    func map() throws -> FeePriorityValue {
        FeePriorityValue(
            priority: try FeePriority(id: priority),
            value: try BigInt.from(string: value)
        )
    }
}

extension GemTransactionMetadata {
    func map() -> TransactionMetadata {
        switch self {
        case .perpetual(let perpetualMetadata):
            return .perpetual(TransactionPerpetualMetadata(
                pnl: perpetualMetadata.pnl,
                price: perpetualMetadata.price
            ))
        }
    }
}

extension TransactionStateRequest {
    func map() -> GemTransactionStateRequest {
        GemTransactionStateRequest(
            id: id,
            senderAddress: senderAddress,
            createdAt: Int64(createdAt.timeIntervalSince1970)
        )
    }
}

// MARK: - Perpetual

extension GatewayService {
    public func getPositions(chain: Primitives.Chain, address: String) async throws -> PerpetualPositionsSummary {
        try await gateway.getPositions(chain: chain.rawValue, address: address).map()
    }
    
    public func getPerpetualsData(chain: Primitives.Chain) async throws -> [PerpetualData] {
        try await gateway.getPerpetualsData(chain: chain.rawValue).map {
            try $0.map()
        }
    }
    
    public func getCandlesticks(chain: Primitives.Chain, symbol: String, period: ChartPeriod) async throws -> [ChartCandleStick] {
        try await gateway.getCandlesticks(chain: chain.rawValue, symbol: symbol, period: period.rawValue).map {
            try $0.map()
        }
    }
}

// MARK: - Perpetual Mapping Extensions

extension GemPerpetualPositionsSummary {
    func map() throws -> PerpetualPositionsSummary {
        PerpetualPositionsSummary(
            positions: try positions.map { try $0.map() },
            balance: balance.map()
        )
    }
}

extension GemPerpetualPosition {
    func map() throws -> PerpetualPosition {
        let assetId = try AssetId(id: assetId)
        return PerpetualPosition(
            id: symbol,
            perpetualId: perpetualId,
            assetId: assetId,
            size: size,
            sizeValue: size * entryPrice,
            leverage: UInt8(leverage),
            entryPrice: entryPrice,
            liquidationPrice: liquidationPrice,
            marginType: try PerpetualMarginType(id: marginType),
            direction: try PerpetualDirection(id: direction),
            marginAmount: margin,
            takeProfit: nil,
            stopLoss: nil,
            pnl: pnl,
            funding: funding
        )
    }
}


extension GemPerpetualBalance {
    func map() -> PerpetualBalance {
        PerpetualBalance(
            available: available,
            reserved: reserved,
            withdrawable: withdrawable
        )
    }
}

extension GemPerpetualData {
    func map() throws -> PerpetualData {
        PerpetualData(
            perpetual: try perpetual.map(),
            asset: try asset.map(),
            metadata: metadata.map()
        )
    }
}

extension GemPerpetual {
    func map() throws -> Perpetual {
        Perpetual(
            id: id,
            name: name,
            provider: try PerpetualProvider(id: provider),
            assetId: try AssetId(id: assetId),
            identifier: identifier,
            price: price,
            pricePercentChange24h: pricePercentChange24h,
            openInterest: openInterest,
            volume24h: volume24h,
            funding: funding,
            leverage: [UInt8](leverage)
        )
    }
}


extension GemAsset {
    func map() throws -> Asset {
        Asset(
            id: try AssetId(id: id),
            name: name,
            symbol: symbol,
            decimals: decimals,
            type: try AssetType(id: assetType)
        )
    }
}


extension GemPerpetualMetadata {
    func map() -> PerpetualMetadata {
        PerpetualMetadata(isPinned: isPinned)
    }
}

extension GemChartCandleStick {
    func map() throws -> ChartCandleStick {
        ChartCandleStick(
            date: Date(timeIntervalSince1970: TimeInterval(timestamp / 1000)),
            open: open,
            high: high,
            low: low,
            close: close,
            volume: volume
        )
    }
}

