// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives
import BigInt

extension TransactionInput {
    public func map() -> GemTransactionLoadInput {
        GemTransactionLoadInput(
            inputType: self.type.map(),
            senderAddress: senderAddress,
            destinationAddress: destinationAddress,
            value: value.description,
            gasPrice: gasPrice.map(),
            memo: memo,
            isMaxValue: feeInput.isMaxAmount,
            metadata: self.metadata.map() 
        )
    }
}

extension GemStakeType {
    public func mapToStakeType(asset: Asset) throws -> StakeType {
        switch self {
        case .delegate(let validator):
            return .stake(validator: try validator.map())
        case .undelegate(let validator):
            // For undelegate, we need a Delegation - using placeholder for now
            let base = DelegationBase(
                assetId: asset.id,
                state: .active,
                balance: "",
                shares: "",
                rewards: "",
                completionDate: nil,
                delegationId: "",
                validatorId: validator.id
            )
            let delegation = Delegation(base: base, validator: try validator.map(), price: nil)
            return .unstake(delegation: delegation)
        case .redelegate(let delegation, let toValidator):
            return .redelegate(delegation: try delegation.map(), toValidator: try toValidator.map())
        case .withdrawRewards(let validators):
            let mappedValidators = try validators.map { try $0.map() }
            return .rewards(validators: mappedValidators)
        case .withdraw(let delegation):
            return .withdraw(delegation: try delegation.map())
        }
    }
}

extension GasPriceType {
    public func map() -> GemGasPriceType {
        switch self {
        case .regular(let gasPrice):
            return .regular(gasPrice: gasPrice.description)
        case .eip1559(let gasPrice, let priorityFee):
            return .eip1559(gasPrice: gasPrice.description, priorityFee: priorityFee.description)
        case .solana(let gasPrice, let priorityFee, let unitPrice):
            return .solana(gasPrice: gasPrice.description, priorityFee: priorityFee.description, unitPrice: unitPrice.description)
        }
    }
}

extension GemGasPriceType {
    public func map() throws -> GasPriceType {
        switch self {
        case .regular(let gasPrice):
            return GasPriceType.regular(gasPrice: try BigInt.from(string: gasPrice))
        case .eip1559(let gasPrice, let priorityFee):
            return GasPriceType.eip1559(gasPrice: try BigInt.from(string: gasPrice), priorityFee: try BigInt.from(string: priorityFee))
        case .solana(let gasPrice, let priorityFee, let unitPrice):
            return GasPriceType.solana(gasPrice: try BigInt.from(string: gasPrice), priorityFee: try BigInt.from(string: priorityFee), unitPrice: try BigInt.from(string: unitPrice))
        }
    }
}

extension GemTransactionInputType {
    public func getAsset() -> GemAsset {
        switch self {
        case .transfer(let asset):
            return asset
        case .swap(let fromAsset, _):
            return fromAsset
        case .stake(let asset, _):
            return asset
        }
    }
    
    public func map() throws -> TransferDataType {
        switch self {
        case .transfer(let gemAsset):
            return TransferDataType.transfer(try gemAsset.map())
        case .swap(let fromAsset, let toAsset):
            // For mapping purposes, create a placeholder SwapData - in real usage this would contain actual swap information
            let swapQuoteData = SwapQuoteData(to: "", value: "", data: "", approval: nil, gasLimit: nil)
            let providerData = SwapProviderData(provider: .uniswapV4, name: "", protocolName: "")
            let swapQuote = SwapQuote(fromValue: "0", toValue: "0", providerData: providerData, walletAddress: "", slippageBps: 0, etaInSeconds: nil)
            let swapData = SwapData(quote: swapQuote, data: swapQuoteData)
            return TransferDataType.swap(try fromAsset.map(), try toAsset.map(), swapData)
        case .stake(let asset, let operation):
            let asset = try asset.map()
            return TransferDataType.stake(asset, try operation.mapToStakeType(asset: asset))
        }
    }
}

extension GemTransactionLoadInput {
    public func map() throws -> TransactionInput {
        return TransactionInput(
            type: try inputType.map(),
            asset: try inputType.getAsset().map(),
            senderAddress: senderAddress,
            destinationAddress: destinationAddress,
            value: try BigInt.from(string: value),
            balance: BigInt.zero, // Would need to be provided from context
            gasPrice: try gasPrice.map(),
            memo: memo,
            metadata: try self.metadata.map()
        )
    }
}

extension TransferDataType {
    public func map() -> GemTransactionInputType {
        switch self {
        case .transfer(let asset):
            return .transfer(asset: asset.map())
        case .swap(let fromAsset, let toAsset, _):
            return .swap(fromAsset: fromAsset.map(), toAsset: toAsset.map())
        case .stake(let asset, let stakeType):
            return .stake(asset: asset.map(), operation: stakeType.map())
        case .deposit, .withdrawal, .transferNft, .tokenApprove, .account, .perpetual, .generic:
            fatalError("Unsupported transaction type: \(self)")
        }
    }
}

extension StakeType {
    public func map() -> GemStakeType {
        switch self {
        case .stake(let validator):
            return .delegate(validator: validator.map())
        case .unstake(let delegation):
            return .undelegate(validator: delegation.validator.map())
        case .redelegate(let delegation, let toValidator):
            return .redelegate(delegation: delegation.map(), toValidator: toValidator.map())
        case .rewards(let validators):
            return .withdrawRewards(validators: validators.map { $0.map() })
        case .withdraw(let delegation):
            return .withdraw(delegation: delegation.map())
        }
    }
}

extension UTXO {
    public func map() -> GemUtxo {
        GemUtxo(
            transactionId: transaction_id,
            vout: UInt32(vout),
            value: value,
            address: address
        )
    }
}

extension Asset {
    public func map() -> GemAsset {
        GemAsset(
            id: id.identifier,
            name: name,
            symbol: symbol,
            decimals: decimals,
            assetType: type.rawValue
        )
    }
}

extension SolanaTokenProgramId {
    public func map() -> GemSolanaTokenProgramId {
        switch self {
        case .token: .token
        case .token2022: .token2022
        }
    }
}

extension GemSolanaTokenProgramId {
    public func map() -> SolanaTokenProgramId {
        switch self {
        case .token: .token
        case .token2022: .token2022
        }
    }
}

extension TransactionLoadMetadata {
    public func map() -> GemTransactionLoadMetadata {
        switch self {
        case .none:
            return .none
        case .solana(let senderTokenAddress, let recipientTokenAddress, let tokenProgram, let blockHash):
            return .solana(
                senderTokenAddress: senderTokenAddress,
                recipientTokenAddress: recipientTokenAddress,
                tokenProgram: tokenProgram?.map(),
                blockHash: blockHash
            )
        case .ton(let jettonWalletAddress, let sequence):
            return .ton(jettonWalletAddress: jettonWalletAddress, sequence: sequence)
        case .cosmos(let accountNumber, let sequence, let chainId):
            return .cosmos(accountNumber: UInt64(accountNumber), sequence: sequence, chainId: chainId)
        case .bitcoin(let utxos):
            return .bitcoin(utxos: utxos.map { $0.map() })
        case .cardano(let utxos):
            return .cardano(utxos: utxos.map { $0.map() })
        case .evm(let nonce, let chainId):
            return .evm(nonce: UInt64(nonce), chainId: UInt64(chainId))
        case .near(let sequence, let blockHash):
            return .near(sequence: sequence, blockHash: blockHash)
        case .stellar(let sequence, let isDestinationAddressExist):
            return .stellar(sequence: sequence, isDestinationAddressExist: isDestinationAddressExist)
        case .xrp(let sequence, let blockNumber):
            return .xrp(sequence: sequence, blockNumber: blockNumber)
        case .algorand(let sequence, let blockHash, let chainId):
            return .algorand(sequence: sequence, blockHash: blockHash, chainId: chainId)
        case .aptos(let sequence):
            return .aptos(sequence: sequence)
        case .polkadot(let sequence, let genesisHash, let blockHash, let blockNumber, let specVersion, let transactionVersion, let period):
            return .polkadot(
                sequence: sequence,
                genesisHash: genesisHash,
                blockHash: blockHash,
                blockNumber: UInt64(blockNumber),
                specVersion: specVersion,
                transactionVersion: transactionVersion,
                period: UInt64(period)
            )
        case .tron(let blockNumber, let blockVersion, let blockTimestamp, let transactionTreeRoot, let parentHash, let witnessAddress):
            return .tron(
                blockNumber: UInt64(blockNumber),
                blockVersion: UInt64(blockVersion),
                blockTimestamp: UInt64(blockTimestamp),
                transactionTreeRoot: transactionTreeRoot,
                parentHash: parentHash,
                witnessAddress: witnessAddress
            )
        case .sui(let messageBytes):
            return .sui(messageBytes: messageBytes)
        }
    }
}

extension Fee {
    public func map() -> Gemstone.GemTransactionLoadFee {
        return Gemstone.GemTransactionLoadFee(
            fee: fee.description,
            gasPriceType: gasPriceType.map(),
            gasLimit: gasLimit.description,
            options: options.map()
        )
    }
}

extension DelegationValidator {
    public func map() -> GemDelegationValidator {
        return GemDelegationValidator(
            chain: chain.rawValue,
            id: id,
            name: name,
            isActive: isActive,
            commission: commision,
            apr: apr
        )
    }
}


extension Delegation {
    public func map() -> GemDelegation {
        return GemDelegation(
            base: base.map(),
            validator: validator.map()
        )
    }
}

extension GemDelegation {
    func map() throws -> Delegation {
        return Delegation(
            base: try base.map(),
            validator: try validator.map(),
            price: nil
        )
    }
}

extension DelegationBase {
    public func map() -> GemDelegationBase {
        return GemDelegationBase(
            assetId: assetId.identifier,
            delegationId: delegationId,
            validatorId: validatorId,
            balance: balance,
            shares: shares,
            completionDate: completionDate.map { UInt64($0.timeIntervalSince1970) },
            delegationState: state.rawValue,
            rewards: rewards
        )
    }
}


extension GemTransactionLoadMetadata {
    public func map() throws -> TransactionLoadMetadata {
        switch self {
        case .none:
            return .none
        case .solana(let senderTokenAddress, let recipientTokenAddress, let tokenProgram, let blockHash):
            return .solana(
                senderTokenAddress: senderTokenAddress,
                recipientTokenAddress: recipientTokenAddress,
                tokenProgram: tokenProgram?.map(),
                blockHash: blockHash
            )
        case .ton(let jettonWalletAddress, let sequence):
            return .ton(jettonWalletAddress: jettonWalletAddress, sequence: sequence)
        case .cosmos(let accountNumber, let sequence, let chainId):
            return .cosmos(accountNumber: UInt64(accountNumber), sequence: sequence, chainId: chainId)
        case .bitcoin(let utxos):
            return .bitcoin(utxos: try utxos.map { try $0.map() })
        case .cardano(let utxos):
            return .cardano(utxos: try utxos.map { try $0.map() })
        case .evm(let nonce, let chainId):
            return .evm(nonce: UInt64(nonce), chainId: UInt64(chainId))
        case .near(let sequence, let blockHash):
            return .near(sequence: sequence, blockHash: blockHash)
        case .stellar(let sequence, let isDestinationAddressExist):
            return .stellar(sequence: sequence, isDestinationAddressExist: isDestinationAddressExist)
        case .xrp(let sequence, let blockNumber):
            return .xrp(sequence: sequence, blockNumber: blockNumber)
        case .algorand(let sequence, let blockHash, let chainId):
            return .algorand(sequence: sequence, blockHash: blockHash, chainId: chainId)
        case .aptos(let sequence):
            return .aptos(sequence: sequence)
        case .polkadot(let sequence, let genesisHash, let blockHash, let blockNumber, let specVersion, let transactionVersion, let period):
            return .polkadot(
                sequence: sequence,
                genesisHash: genesisHash,
                blockHash: blockHash,
                blockNumber: UInt64(blockNumber),
                specVersion: specVersion,
                transactionVersion: transactionVersion,
                period: UInt64(period)
            )
        case .tron(let blockNumber, let blockVersion, let blockTimestamp, let transactionTreeRoot, let parentHash, let witnessAddress):
            return .tron(
                blockNumber: UInt64(blockNumber),
                blockVersion: UInt64(blockVersion),
                blockTimestamp: UInt64(blockTimestamp),
                transactionTreeRoot: transactionTreeRoot,
                parentHash: parentHash,
                witnessAddress: witnessAddress
            )
        case .sui(let messageBytes):
            return .sui(messageBytes: messageBytes)
        }
    }
}

