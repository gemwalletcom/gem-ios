// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import BigInt
import GemstonePrimitives

public struct StellarService: Sendable {
    
    let valueFormatter = ValueFormatter.full
    
    let chain: Chain
    let provider: Provider<StellarProvider>
    
    public init(
        chain: Chain,
        provider: Provider<StellarProvider>
    ) {
        self.chain = chain
        self.provider = provider
    }
}

// MARK: - Business Logic

extension StellarService {
    private func account(address: String) async throws -> StellarAccount {
        try await provider
            .request(.account(address: address))
            .mapOrCatch(as: StellarAccount.self, codes: [404], result: .empty)
    }
    
    private func isAccountExists(address: String) async throws -> Bool {
        try await account(address: address).isEmpty == false
    }
    
    private func nodeStatus() async throws -> StellarNodeStatus {
        try await provider
            .request(.node)
            .map(as: StellarNodeStatus.self)
    }
    
    private func latestBlock() async throws -> BigInt {
        BigInt(try await nodeStatus().ingest_latest_ledger)
    }
    
    private func reservedBalance() -> BigInt {
        BigInt(chain.accountActivationFee ?? 0)
    }
}

// MARK: - ChainBalanceable

extension StellarService: ChainBalanceable {
    public func coinBalance(for address: String) async throws -> AssetBalance {
        let balance = try await account(address: address)
            .balances
            .first( where: { $0.asset_type == "native" })?.balance
        
        let (available, reserved): (BigInt, BigInt) = try {
            if let balance = balance {
                let reserved = reservedBalance()
                let balance = try valueFormatter.inputNumber(from: balance, decimals: chain.asset.decimals.asInt)
                return (
                    max(balance - reserved, .zero),
                    reserved
                )
            } else {
                return (.zero, .zero)
            }
        }()
        
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

extension StellarService: ChainFeeRateFetchable {
    public func feeRates(type: TransferDataType) async throws -> [FeeRate] {
        let fees = try await provider
            .request(.fee)
            .map(as: StellarFees.self)

        let min = max(BigInt(stringLiteral: fees.fee_charged.min), BigInt(stringLiteral: fees.last_ledger_base_fee))
        
        return [
            FeeRate(priority: .slow, gasPriceType: .regular(gasPrice: min)),
            FeeRate(priority: .normal, gasPriceType: .regular(gasPrice: min)),
            FeeRate(priority: .fast, gasPriceType: .regular(gasPrice: BigInt(stringLiteral: fees.fee_charged.p95) * 2)),
        ]
    }
}

// MARK: - ChainTransactionPreloadable

extension StellarService: ChainTransactionPreloadable {
    public func load(input: TransactionInput) async throws -> TransactionPreload {
        async let getAccount = account(address: input.senderAddress)
        async let getIsDestinationAccountExist = isAccountExists(address: input.destinationAddress)
        let (account, isDestinationAccountExist) = try await (getAccount, getIsDestinationAccountExist)
        
        guard let sequence = Int(account.sequence) else {
            throw AnyError("invalid sequence")
        }
        let fee: Fee = {
            if isDestinationAccountExist { input.defaultFee } else {
                Fee(
                    fee: input.defaultFee.fee,
                    gasPriceType: input.defaultFee.gasPriceType,
                    gasLimit: input.defaultFee.gasLimit,
                    options: [.tokenAccountCreation: .zero]
                )
            }
        }()
        
        return TransactionPreload(
            sequence: sequence + 1,
            fee: fee
        )
    }
}

// MARK: - ChainBroadcastable

extension StellarService: ChainBroadcastable {
    public func broadcast(data: String, options: BroadcastOptions) async throws -> String {
        let transaction = try await provider
            .request(.broadcast(data: data))
            .mapOrError(as: StellarTransactionBroadcast.self, asError: StellarTransactionBroadcastError.self)
        
        return transaction.hash
    }
}

// MARK: - ChainTransactionStateFetchable

extension StellarService: ChainTransactionStateFetchable {
    public func transactionState(for request: TransactionStateRequest) async throws -> TransactionChanges {
        let transaction = try await provider
            .request(.transaction(id: request.id))
            .map(as: StellarTransactionStatus.self)
        
        let state: TransactionState = transaction.successful ? .confirmed : .failed
        let networkFee = BigInt(stringLiteral: transaction.fee_charged)
        
        return TransactionChanges(state: state, changes: [.networkFee(networkFee)])
    }
}

// MARK: - ChainSyncable

extension StellarService: ChainSyncable {
    public func getInSync() async throws -> Bool {
        //TODO: Add getInSync check later
        true
    }
}

// MARK: - ChainStakable

extension StellarService: ChainStakable {
    public func getValidators(apr: Double) async throws -> [DelegationValidator] {
        return []
    }

    public func getStakeDelegations(address: String) async throws -> [DelegationBase] {
        fatalError()
    }
}

// MARK: - ChainTokenable

extension StellarService: ChainTokenable {
    public func getTokenData(tokenId: String) async throws -> Asset {
        throw AnyError("Not Implemented")
    }
    
    public func getIsTokenAddress(tokenId: String) -> Bool {
        false
    }
}

// MARK: - ChainIDFetchable
 
extension StellarService: ChainIDFetchable {
    public func getChainID() async throws -> String {
        try await nodeStatus().network_passphrase
    }
}

// MARK: - ChainLatestBlockFetchable

extension StellarService: ChainLatestBlockFetchable {
    public func getLatestBlock() async throws -> BigInt {
        try await latestBlock()
    }
}


// MARK: - ChainAddressStatusFetchable

extension StellarService: ChainAddressStatusFetchable {
    public func getAddressStatus(address: String) async throws -> [AddressStatus] {
        []
    }
}

extension StellarTransactionBroadcastError: LocalizedError {
    public var errorDescription: String? {
        title
    }
}

extension StellarAccount {
    static let empty = StellarAccount(sequence: "", balances: [])
    
    var isEmpty: Bool {
        sequence.isEmpty && balances.isEmpty
    }
}
