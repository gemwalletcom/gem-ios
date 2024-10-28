// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import BigInt
import WalletCore

public struct TronService: Sendable {
    
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
        try await provider
            .request(.latestBlock)
            .map(as: TronBlock.self)
    }

    private func account(address: String) async throws -> TronAccount {
        try await provider
            .request(.account(address: address))
            .map(as: TronAccount.self)
    }

    private func accountUsage(address: String) async throws -> TronAccountUsage {
        try await provider
            .request(.accountUsage(address: address))
            .map(as: TronAccountUsage.self)
    }

    private func reward(address: String) async throws -> BigInt {
        let reward = try await provider
            .request(.getReward(address: address))
            .map(as: TronRewards.self).reward
        return BigInt(reward)
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

    private func addressBase58(hex: String) throws -> String {
        guard let data = Data(hexString: hex) else {
            throw AnyError("Invalid hex address: \(hex)")
        }
        return Base58.encode(data: data)
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
        async let getAccount = account(address: address)
        async let getReward = reward(address: address)

        let (account, rewards) = try await (getAccount, getReward)

        let availableBalance = BigInt(account.balance ?? 0)

        let pendingBalance = account.unfrozenV2?
            .compactMap { unfrozen in
                guard let amount = unfrozen.unfreeze_amount else { return nil }
                return BigInt(amount)
            }
            .reduce(0, +) ?? BigInt(0)


        let frozenBalance = account.frozenV2?
            .compactMap { BigInt($0.amount ?? 0) }
            .reduce(0, +) ?? BigInt(0)

        let votes = account.votes ?? []
        let totalVotes = votes.reduce(0) { $0 + $1.vote_count }
        let votesBalance = BigInt(totalVotes) * BigInt(10).power(Int(chain.asset.decimals))

        return AssetBalance(
            assetId: chain.assetId,
            balance: Balance(
                available: availableBalance,
                frozen: frozenBalance - votesBalance,
                locked: BigInt(0),
                staked: votesBalance,
                pending: pendingBalance,
                rewards: rewards,
                reserved: BigInt(0)
            )
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
        let fee = try await {
            switch input.type {
            case .transfer(let asset):
                async let getParameters = parameters()
                async let getAccountUsage = accountUsage(address: input.senderAddress)
                async let getIsNewAccount = isNewAccount(address: input.destinationAddress)
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

                switch asset.type {
                case .native:
                    let availableBandwidth = (accountUsage.freeNetLimit ?? 0) - (accountUsage.freeNetUsed ?? 0)
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
            case let .stake(_, type):
                async let getAccountUsage = accountUsage(address: input.senderAddress)
                async let getAccountBalance = coinBalance(for: input.senderAddress)

                let (accountUsage, accountBalance) = try await (getAccountUsage, getAccountBalance.balance)

                let availableBandwidth = (accountUsage.freeNetLimit ?? 0) - (accountUsage.freeNetUsed ?? 0)
                switch type {
                case .stake:
                    let needFreeze = input.value > accountBalance.frozen + accountBalance.staked
                    if needFreeze {
                        return availableBandwidth >= 580 ? BigInt.zero : BigInt(280_000 * 2)
                    }
                    return availableBandwidth >= 300 ? BigInt.zero : BigInt(280_000)
                case .rewards, .withdraw, .redelegate, .unstake:
                    return availableBandwidth >= 300 ? BigInt.zero : BigInt(280_000)
                }
            case .generic, .swap:
                fatalError()
            }
        }()
        
        return Fee(
            fee: fee,
            gasPriceType: .regular(gasPrice: fee),
            gasLimit: 1,
            feeRates: [],
            selectedFeeRate: nil
        )
    }

    public func feeRates() async throws -> [FeeRate] { fatalError("not implemented") }
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
        //TODO: Add getInSync check later
        true
    }
}

// MARK: - ChainStakable

extension TronService: ChainStakable {
    public func getValidators(apr: Double) async throws -> [DelegationValidator] {
        let unstackingEmptyValidator = DelegationValidator(
            chain: chain,
            id: "Unstacking",
            name: "Unstacking",
            isActive: true,
            commision: 0,
            apr: 0
        )

        return try await provider
            .request(.listwitnesses)
            .map(as: WitnessesList.self).witnesses
            .map {
                DelegationValidator(
                    chain: chain,
                    id: try addressBase58(hex: $0.address),
                    name: .empty,
                    isActive: $0.isJobs ?? false,
                    commision: 0,
                    apr: 0
                )
            } + [unstackingEmptyValidator]
    }

    public func getStakeDelegations(address: String) async throws -> [DelegationBase] {
        async let getAccount = account(address: address)
        async let getReward = reward(address: address)//account(address: address)
        async let getVlidators = getValidators(apr: 0)

        let (account, reward, validators) = try await (
            getAccount,
            getReward,
            getVlidators
        )

        let pendingDelegations: [DelegationBase] = (account.unfrozenV2 ?? []).compactMap { unfrozen in
            guard let expireTime = unfrozen.unfreeze_expire_time,
                  let amount = unfrozen.unfreeze_amount else { return nil }

            let completionDate = Date(timeIntervalSince1970: TimeInterval(expireTime / 1000))
            let balance = BigInt(amount)

            return DelegationBase(
                assetId: chain.assetId,
                state: Date() < completionDate ? .pending : .awaitingWithdrawal,
                balance: BigInt(balance).description,
                shares: .empty,
                rewards: "0",
                completionDate: completionDate,
                delegationId: completionDate.description,
                validatorId: "Unstacking"
            )
        }

        let votes = account.votes ?? []
        let totalVotes = votes.reduce(0) { $0 + $1.vote_count }

        let delegations: [DelegationBase] = votes.compactMap { vote -> DelegationBase? in
            guard let validator = validators.first(where: { $0.id == vote.vote_address }) else {
                print("Validator with address \(vote.vote_address) not found in the validators list.")
                return nil
            }

            let rewards: String = {
                guard totalVotes > 0 else { return String(reward) }
                let proportion = Double(vote.vote_count) / Double(totalVotes)
                let rewardForVote = (Double(reward) * proportion)
                return String(format: "%.0f", rewardForVote)
            }()

            let balance = (BigInt(vote.vote_count) * BigInt(10).power(Int(chain.asset.decimals))).description

            return DelegationBase(
                assetId: chain.assetId,
                state: .active,
                balance: balance,
                shares: .empty,
                rewards: rewards,
                completionDate: nil,
                delegationId: "\(balance)_\(rewards)",
                validatorId: validator.id
            )
        }
        return delegations + pendingDelegations
    }
}

// MARK: - ChainIDFetchable
 
extension TronService: ChainIDFetchable {
    public func getChainID() async throws -> String {
        //TODO: Add getChainID check later
        return ""
    }
}

// MARK: - ChainLatestBlockFetchable

extension TronService: ChainLatestBlockFetchable {
    public func getLatestBlock() async throws -> BigInt {
        try await latestBlock().block_header.raw_data.number.asBigInt
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

// MARK: - ChainAddressStatusFetchable

extension TronService: ChainAddressStatusFetchable {
    public func getAddressStatus(address: String) async throws -> [AddressStatus] {
        let account = try await account(address: address)
        let permissions = account.active_permission ?? []
        if !permissions.filter({ $0.threshold > 1 }).isEmpty {
            return [.multiSignature]
        }
        return []
    }
}
