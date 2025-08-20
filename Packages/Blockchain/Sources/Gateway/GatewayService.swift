// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives
import BigInt
import NativeProviderService

public actor GatewayService: Sendable {
    let gateway: GemGateway
    
    public init(
        provider: NativeProvider
    ) {
        self.gateway = GemGateway(provider: provider)
    }
}

extension GatewayService: GemGatewayEstimateFee {
    public func getFee(chain: Gemstone.Chain, input: Gemstone.GemTransactionLoadInput) async throws -> Gemstone.GemTransactionLoadFee? {
        try await EstimateFeeService().getFee(chain: chain, input: input)
    }
    
    public func getFeeData(chain: Gemstone.Chain, input: GemTransactionLoadInput) async throws -> String? {
        try await EstimateFeeService().getFeeData(chain: chain, input: input)
    }
}

// MARK: - Balances

extension GatewayService {
    public func coinBalance(chain: Primitives.Chain, address: String) async throws -> AssetBalance {
        try await gateway.getBalanceCoin(chain: chain.rawValue, address: address).map()
    }

    public func tokenBalance(chain: Primitives.Chain, address: String, tokenIds: [Primitives.AssetId]) async throws -> [AssetBalance] {
        try await gateway
            .getBalanceTokens(chain: chain.rawValue, address: address, tokenIds: tokenIds.compactMap(\.tokenId))
            .map { try $0.map() }
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
        let changes: [TransactionChange] = try update.changes.compactMap {
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
    
    public func feeRates(chain: Primitives.Chain) async throws -> [FeeRate] {
        try await gateway.getFeeRates(chain: chain.rawValue).map { try $0.map() }
    }
}

// MARK: - Token

extension GatewayService {
    public func tokenData(chain: Primitives.Chain, tokenId: String) async throws -> Asset {
        try await gateway.getTokenData(chain: chain.rawValue, tokenId: tokenId).map()
    }
    
    public func isTokenAddress(chain: Primitives.Chain, tokenId: String) async throws -> Bool {
        try await gateway.getIsTokenAddress(chain: chain.rawValue, tokenId: tokenId)
    }
}

// MARK: - Transaction Preload

extension GatewayService {
    public func transactionPreload(chain: Primitives.Chain, input: TransactionPreloadInput) async throws -> TransactionLoadMetadata {
        try await gateway.getTransactionPreload(chain: chain.rawValue, input: input.map()).map()
    }
    
    public func transactionLoad(chain: Primitives.Chain, input: GemTransactionLoadInput) async throws -> TransactionData {
        try await gateway.getTransactionLoad(chain: chain.rawValue, input: input, provider: self).map()
    }
}

// MARK: - Staking

extension GatewayService {
    public func validators(chain: Primitives.Chain) async throws -> [DelegationValidator] {
        do {
            let validators = try await gateway.getStakingValidators(chain: chain.rawValue, apy: nil)
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
            balance: try balance.map(),
            isActive: isActive
        )
    }
}

extension TransactionPreloadInput {
    func map() -> GemTransactionPreloadInput {
        GemTransactionPreloadInput(
            senderAddress: senderAddress,
            destinationAddress: destinationAddress
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
            chain: try Chain(id: chain),
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
            assetId: try AssetId(id: assetId),
            state: try DelegationState(id: delegationState),
            balance: balance,
            shares: shares,
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
            address: address
        )
    }
}

extension GemFeeRate {
    func map() throws -> FeeRate {
        let gasPrice = try BigInt.from(string: gasPriceType.gasPrice)
        let gasPriceType: GasPriceType = try {
            if let priorityFee = self.gasPriceType.priorityFee {
                return .eip1559(gasPrice: gasPrice, priorityFee: try BigInt.from(string: priorityFee))
            } else {
                return .regular(gasPrice: gasPrice)
            }
        }()
       
        return FeeRate(
            priority: try FeePriority(id: priority), 
            gasPriceType: gasPriceType
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
            createdAt: Int64(createdAt.timeIntervalSince1970),
            blockNumber: Int64(block)
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
            date: Date(timeIntervalSince1970: TimeInterval(timestamp)),
            open: open,
            high: high,
            low: low,
            close: close,
            volume: volume
        )
    }
}

extension GemTransactionData {
    func map() throws -> TransactionData {
        let transactionFee = Fee(
            fee: try BigInt.from(string: fee.fee),
            gasPriceType: .regular(gasPrice: try BigInt.from(string: fee.gasPrice)),
            gasLimit: try BigInt.from(string: fee.gasLimit),
            options: try fee.options.map()
        )
        switch metadata {
        case .none:
            return TransactionData(fee: transactionFee)
        case .solana(let senderTokenAddress, let recipientTokenAddress, let tokenProgram, let sequence):
            return TransactionData(
                sequence: Int(sequence),
                token: SignerInputToken(
                    senderTokenAddress: senderTokenAddress,
                    recipientTokenAddress: recipientTokenAddress,
                    tokenProgram: tokenProgram.map()
                ),
                fee: transactionFee
            )
            
        case .ton(let jettonWalletAddress, let sequence):
            return TransactionData(
                sequence: Int(sequence),
                token: SignerInputToken(
                    senderTokenAddress: jettonWalletAddress,
                    recipientTokenAddress: nil,
                    tokenProgram: .token
                ),
                fee: transactionFee
            )
        case .cosmos(let accountNumber, let sequence, let chainId):
            return TransactionData(
                accountNumber: Int(accountNumber),
                sequence: Int(sequence),
                chainId: chainId,
                fee: transactionFee
            )
        case .bitcoin(let utxos),
            .cardano(let utxos):
            return TransactionData(
                fee: transactionFee,
                utxos: try utxos.map { try $0.map() }
            )
            
        case .evm(let nonce, let chainId):
            return TransactionData(
                sequence: Int(nonce),
                chainId: String(chainId),
                fee: transactionFee
            )
            
        case .near(let sequence, let blockHash, _):
            return TransactionData(
                sequence: Int(sequence),
                block: SignerInputBlock(
                    number: 0,
                    hash: blockHash
                ),
                fee: transactionFee
            )
            
        case .stellar(let sequence, _),
            .xrp(let sequence),
            .algorand(let sequence),
            .aptos(let sequence):
            return TransactionData(
                sequence: Int(sequence),
                fee: transactionFee
            )
            
        case .polkadot(let sequence, let genesisHash, let blockHash, let blockNumber, let specVersion, let transactionVersion, let period):
            return TransactionData(
                sequence: Int(sequence),
                data: .polkadot(SigningData.Polkadot(
                    genesisHash: try Data.from(hex: genesisHash),
                    blockHash: try Data.from(hex: blockHash),
                    blockNumber: UInt64(blockNumber),
                    specVersion: UInt32(specVersion),
                    transactionVersion: UInt32(transactionVersion),
                    period: UInt64(period)
                )),
                block: SignerInputBlock(number: Int(blockNumber)),
                fee: transactionFee
            )
        case .tron(
            let blockNumber,
            let blockVersion,
            let blockTimestamp,
            let transactionTreeRoot,
            let parentHash,
            let witnessAddress):
            return TransactionData(
                block: SignerInputBlock(
                    number: Int(blockNumber),
                    version: Int(blockVersion),
                    timestamp: Int(blockTimestamp),
                    transactionTreeRoot: transactionTreeRoot,
                    parentHash: parentHash,
                    widnessAddress: witnessAddress
                ),
                fee: transactionFee
            )
        }
    }
}
