// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import BigInt
import WalletCore

public struct TronService {
    
    let chain: Chain
    let provider: Provider<TronProvider>
    
    public init(
        chain: Chain,
        provider: Provider<TronProvider>
    ) {
        self.chain = chain
        self.provider = provider
    }
}

// MARK: - Business Logic

extension TronService {
    private func latestBlock() async throws -> TronBlock {
        return try await provider
            .request(.latestBlock)
            .map(as: TronBlock.self)
    }

    private func account(address: String) async throws -> TronAccount {
        return try await provider
            .request(.account(address: address))
            .map(as: TronAccount.self)
    }

    private func accountUsage(address: String) async throws -> TronAccountUsage {
        return try await provider
            .request(.accountUsage(address: address))
            .map(as: TronAccountUsage.self)
    }

    private func tokenBalance(ownerAddress: String, contractAddress: String) async throws -> BigInt {
        let call = TronSmartContractCall(
            contract_address: contractAddress,
            function_selector: "balanceOf(address)",
            //TODO: Add padding if address has empty zeros in the begining.
            parameter: ownerAddress.addPadding(number: 64, padding: "0"),
            fee_limit: 1_000_000,
            call_value: 0,
            owner_address: ownerAddress,
            visible: false
        )
        let result = try await provider
            .request(.triggerSmartContract(call))
            .map(as: TronSmartContractResult.self)

        guard let constantResult = result.constant_result.first else {
            return .zero
        }
        return try BigInt.fromHex(constantResult)
    }

    private func addressHex(address: String) throws -> String {
        guard let address = Base58.decode(string: address)?.hexString else {
            throw AnyError("Invalid address")
        }
        return String(address.dropFirst(2))
    }

    // https://developers.tron.network/docs/set-feelimit#how-to-estimate-energy-consumption
    private func estimateTRC20Transfer(ownerAddress: String, recipientAddress: String, contractAddress: String, value: BigInt) async throws -> BigInt {
        let address = try addressHex(address: recipientAddress)
        let parameter = [address, value.hexString].map { $0.addPadding(number: 64, padding: "0") }.joined(separator: "")
        let call = TronSmartContractCall(
            contract_address: contractAddress,
            function_selector: "transfer(address,uint256)",
            parameter: parameter,
            fee_limit: 0,
            call_value: 0,
            owner_address: ownerAddress,
            visible: true
        )
        let result = try await provider
            .request(.triggerSmartContract(call))
            .map(as: TronSmartContractResult.self)

        if let message = result.result.message {
            throw AnyError(message)
        }

        return BigInt(result.energy_used)
    }

    private func parameters() async throws -> [TronChainParameter] {
        return try await provider
            .request(.chainParams)
            .map(as: TronChainParameters.self).chainParameter
    }

    private func isNewAccount(address: String) async throws -> Bool {
        return try await provider
            .request(.account(address: address))
            .map(as: TronEmptyAccount.self).address?.isEmpty ?? true
    }

    private func smartContractCallFunction(contract: String, function: String) async throws -> String {
        let contract = "41" + (try addressHex(address: contract))
        let call = TronSmartContractCall(
            contract_address: contract,
            function_selector: function,
            parameter: .none,
            fee_limit: .none,
            call_value: .none,
            owner_address: contract,
            visible: .none
        )
        let result = try await provider
            .request(.triggerSmartContract(call))
            .map(as: TronSmartContractResult.self)

        guard
            let constantResult = result.constant_result.first  else {
                throw AnyError("Invalid value")
        }
        return constantResult
    }

    private func tokenString(contract: String, function: String) async throws -> String {
        let result = try await smartContractCallFunction(contract: contract, function: function)
        guard let value = EthereumService.decodeABI(hexString: result) else {
            throw AnyError("Invalid value")
        }
        return value
    }

    private func tokenName(contract: String) async throws -> String {
        try await tokenString(contract: contract, function: "name()")
    }

    private func tokenSymbol(contract: String) async throws -> String {
        try await tokenString(contract: contract, function: "symbol()")
    }

    private func tokenDecimals(contract: String) async throws -> BigInt {
        let result = try await smartContractCallFunction(contract: contract, function: "decimals()")
        let decimals = try BigInt.fromHex(result)
        return decimals
    }
}

// MARK: - ChainBalanceable

extension TronService: ChainBalanceable {
    public func coinBalance(for address: String) async throws -> AssetBalance {
        let account = try await account(address: address)
        let balance = account.balance ?? 0
        return Primitives.AssetBalance(
            assetId: chain.assetId,
            balance: Balance(available: BigInt(balance))
        )
    }
    
    public func tokenBalance(for address: String, tokenIds: [AssetId]) async throws -> [AssetBalance] {
        var result: [AssetBalance] = []
        for tokenId in tokenIds {
            guard
                let address = Base58.decode(string: address),
                let token = tokenId.tokenId,
                let contract = Base58.decode(string: token) else {
                break
            }
            let balance = try await tokenBalance(ownerAddress: address.hexString, contractAddress: contract.hexString)
            result.append(AssetBalance(assetId: tokenId, balance: Balance(available: balance)))
        }
        
        return result
    }

    public func getStakeBalance(address: String) async throws -> AssetBalance {
        fatalError()
    }
}

// MARK: - ChainFeeCalculateable

extension TronService: ChainFeeCalculateable {
    public func fee(input: FeeInput) async throws -> Fee {
        async let getParameters = parameters()
        async let getIsNewAccount = isNewAccount(address: input.destinationAddress)
        async let getAccountUsage = accountUsage(address: input.senderAddress)
        let (parameters, isNewAccount, accountUsage) = try await (
            getParameters,
            getIsNewAccount,
            getAccountUsage
        )
        
        guard
            let newAccountFeeInSmartContract = parameters.first(where: { $0.key == TronChainParameterKey.getCreateNewAccountFeeInSystemContract.rawValue })?.value,
            let newAccountFee = parameters.first(where: { $0.key == TronChainParameterKey.getCreateAccountFee.rawValue })?.value,
            let energyFee = parameters.first(where: { $0.key == TronChainParameterKey.getEnergyFee.rawValue })?.value else {
            throw AnyError("unknown key")
        }
        
        let fee = try await {
            switch input.type {
            case .transfer(let asset):
                switch asset.type {
                case .native:
                    let availableBandwidth = accountUsage.freeNetLimit ?? 0 - (accountUsage.freeNetUsed ?? 0)
                    let coinTransferFee = availableBandwidth >= 300 ? BigInt.zero : BigInt(280_000)
                    return isNewAccount ? coinTransferFee + BigInt(newAccountFee + newAccountFeeInSmartContract) : coinTransferFee
                default:
                    let gasLimit = try await estimateTRC20Transfer(
                        ownerAddress: input.senderAddress,
                        recipientAddress: input.destinationAddress,
                        contractAddress: try asset.getTokenId(),
                        value: input.value
                    )
                    let tokenTransferFee = BigInt(energyFee) * gasLimit.increase(byPercentage: 20)
                    return isNewAccount ? tokenTransferFee + BigInt(newAccountFeeInSmartContract) : tokenTransferFee
                }
            case .generic, .swap, .stake:
                fatalError()
            }
        }()
        
        return Fee(
            fee: fee,
            gasPriceType: .regular(gasPrice: fee),
            gasLimit: 1
        )
    }
}

// MARK: - ChainTransactionPreloadable

extension TronService: ChainTransactionPreloadable {
    public func load(input: TransactionInput) async throws -> TransactionPreload {
        async let block = latestBlock().block_header.raw_data
        async let fee = fee(input: input.feeInput)

        return try await TransactionPreload(
            block: SignerInputBlock(
                number: Int(block.number),
                version: Int(block.version),
                timestamp: Int(block.timestamp),
                transactionTreeRoot: block.txTrieRoot,
                parentHash: block.parentHash,
                widnessAddress: block.witness_address
            ),
            fee: fee
        )
    }
}

// MARK: - ChainBroadcastable

extension TronService: ChainBroadcastable {
    public func broadcast(data: String, options: BroadcastOptions) async throws -> String {
        return try await provider
            .request(.broadcast(data: data))
            .mapOrError(
                as: TronTransactionBroadcast.self,
                asError: TronTransactionBroadcastError.self
            ).txid
    }
}

// MARK: - ChainTransactionStateFetchable

extension TronService: ChainTransactionStateFetchable {
    public func transactionState(for id: String, senderAddress: String) async throws -> TransactionChanges {
        let transaction = try await provider
            .request(.transactionReceipt(id: id))
            .map(as: TronTransactionReceipt.self)
    
        if let receipt = transaction.receipt {
            if receipt.result == "OUT_OF_ENERGY" {
                return TransactionChanges(state: .reverted)
            }
        }
    
        if let result = transaction.result, result == "FAILED" {
            return TransactionChanges(state: .reverted)
        }
        
        if transaction.blockNumber > 0 {
            let fee = transaction.fee ?? 0
            return TransactionChanges(state: .confirmed, changes: [.networkFee(BigInt(fee))])
        }
        
        return TransactionChanges(state: .pending)
    }
}

// MARK: - ChainSyncable

extension TronService: ChainSyncable {
    public func getInSync() async throws -> Bool {
        throw AnyError("Not Implemented")
    }
}

// MARK: - ChainStakable

extension TronService: ChainStakable {
    public func getValidators(apr: Double) async throws -> [DelegationValidator] {
        return []
    }

    public func getStakeDelegations(address: String) async throws -> [DelegationBase] {
        fatalError()
    }
}

// MARK: - ChainIDFetchable
 
extension TronService: ChainIDFetchable {
    public func getChainID() async throws -> String? {
        throw AnyError("Not Implemented")
    }
}

// MARK: - ChainLatestBlockFetchable

extension TronService: ChainLatestBlockFetchable {
    public func getLatestBlock() async throws -> BigInt {
        throw AnyError("Not Implemented")
    }
}

// MARK: - ChainTokenable

extension TronService: ChainTokenable {
    public func getTokenData(tokenId: String) async throws -> Asset {
        guard let address = WalletCore.AnyAddress(string: tokenId, coin: chain.coinType)?.description else {
            throw TokenValidationError.invalidTokenId
        }
        let assetId = AssetId(chain: chain, tokenId: address)
        
        async let getName = tokenName(contract: address)
        async let getSymbol = tokenSymbol(contract: address)
        async let getDecimals = tokenDecimals(contract: address)
        
        let (name, symbol, decimals) = try await (getName, getSymbol, getDecimals)
        
        return Asset(
            id: assetId,
            name: name,
            symbol: symbol,
            decimals: decimals.int.asInt32,
            type: assetId.assetType!
        )
    }
    
    public func getIsTokenAddress(tokenId: String) -> Bool {
        tokenId.hasPrefix("T") && tokenId.count.isBetween(30, and: 50)
    }
}

// MARK: - LocalizedError

extension TronTransactionBroadcastError: LocalizedError {
    public var errorDescription: String? {
        if let data = Data(hexString: message), let text = String(data: data, encoding: .utf8) {
            return text
        }
        return message
    }
}
