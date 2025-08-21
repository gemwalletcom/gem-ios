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
            gasPrice: GemGasPriceType(gasPrice: gasPrice.gasPrice.description, priorityFee: nil),
            memo: memo,
            isMaxValue: feeInput.isMaxAmount,
            metadata: self.metadata.map() 
        )
    }
}

extension GemStakeOperation {
    public func mapToStakeType(asset: Asset) throws -> StakeType {
        switch self {
        case .delegate(let validatorAddress):
            // For delegate, we need a DelegationValidator - using placeholder for now
            let validator = DelegationValidator(
                chain: asset.chain, // Use the asset's chain
                id: validatorAddress,
                name: "",
                isActive: true,
                commision: 0,
                apr: 0
            )
            return .stake(validator: validator)
        case .undelegate(let validatorAddress):
            // For undelegate, we need a Delegation - using placeholder for now
            let base = DelegationBase(
                assetId: asset.id,
                state: .active,
                balance: "",
                shares: "",
                rewards: "",
                completionDate: nil,
                delegationId: "",
                validatorId: validatorAddress
            )
            let validator = DelegationValidator(
                chain: asset.chain,
                id: validatorAddress,
                name: "",
                isActive: true,
                commision: 0,
                apr: 0
            )
            let delegation = Delegation(base: base, validator: validator, price: nil)
            return .unstake(delegation: delegation)
        case .redelegate(let srcValidatorAddress, let dstValidatorAddress):
            let base = DelegationBase(
                assetId: asset.id,
                state: .active,
                balance: "",
                shares: "",
                rewards: "",
                completionDate: nil,
                delegationId: "",
                validatorId: srcValidatorAddress
            )
            let srcValidator = DelegationValidator(
                chain: asset.chain,
                id: srcValidatorAddress,
                name: "",
                isActive: true,
                commision: 0,
                apr: 0
            )
            let delegation = Delegation(base: base, validator: srcValidator, price: nil)
            let toValidator = DelegationValidator(
                chain: asset.chain,
                id: dstValidatorAddress,
                name: "",
                isActive: true,
                commision: 0,
                apr: 0
            )
            return .redelegate(delegation: delegation, toValidator: toValidator)
        case .withdrawRewards(let validatorAddresses):
            let validators = validatorAddresses.map { address in
                DelegationValidator(
                    chain: asset.chain,
                    id: address,
                    name: "",
                    isActive: true,
                    commision: 0,
                    apr: 0
                )
            }
            return .rewards(validators: validators)
        }
    }
}

extension GemGasPriceType {
    public func map() throws -> GasPriceType {
        let gasPrice = try BigInt.from(string: gasPrice)
        if let priorityFee = priorityFee {
            return GasPriceType.eip1559(gasPrice: gasPrice, priorityFee: try BigInt.from(string: priorityFee))
        } else {
            return GasPriceType.regular(gasPrice: gasPrice)
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
            return .stake(asset: asset.map(), operation: stakeType.mapToStakeOperation(asset: asset))
        case .deposit, .withdrawal, .transferNft, .tokenApprove, .account, .perpetual, .generic:
            fatalError("Unsupported transaction type: \(self)")
        }
    }
}

extension StakeType {
    public func mapToStakeOperation(asset: Asset) -> GemStakeOperation {
        switch self {
        case .stake(let validator):
            return .delegate(validatorAddress: validator.id)
        case .unstake(let delegation):
            return .undelegate(validatorAddress: delegation.validator.id)
        case .redelegate(let delegation, let toValidator):
            return .redelegate(srcValidatorAddress: delegation.validator.id, dstValidatorAddress: toValidator.id)
        case .rewards(let validators):
            let validatorIds = validators.map { $0.id }
            return .withdrawRewards(validatorAddresses: validatorIds)
        case .withdraw(let delegation):
            return .withdrawRewards(validatorAddresses: [delegation.validator.id])
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
        case .solana(let senderTokenAddress, let recipientTokenAddress, let tokenProgram, let sequence):
            return .solana(
                senderTokenAddress: senderTokenAddress,
                recipientTokenAddress: recipientTokenAddress,
                tokenProgram: tokenProgram.map(),
                sequence: sequence
            )
        case .ton(let jettonWalletAddress, let sequence):
            return .ton(jettonWalletAddress: jettonWalletAddress, sequence: sequence)
        case .cosmos(let accountNumber, let sequence, let chainId):
            return .cosmos(accountNumber: accountNumber, sequence: sequence, chainId: chainId)
        case .bitcoin(let utxos):
            return .bitcoin(utxos: utxos.map { $0.map() })
        case .cardano(let utxos):
            return .cardano(utxos: utxos.map { $0.map() })
        case .evm(let nonce, let chainId):
            return .evm(nonce: nonce, chainId: chainId)
        case .near(let sequence, let blockHash, let isDestinationAddressExist):
            return .near(sequence: sequence, blockHash: blockHash, isDestinationAddressExist: isDestinationAddressExist)
        case .stellar(let sequence, let isDestinationAddressExist):
            return .stellar(sequence: sequence, isDestinationAddressExist: isDestinationAddressExist)
        case .xrp(let sequence):
            return .xrp(sequence: sequence)
        case .algorand(let sequence):
            return .algorand(sequence: sequence)
        case .aptos(let sequence):
            return .aptos(sequence: sequence)
        case .polkadot(let sequence, let genesisHash, let blockHash, let blockNumber, let specVersion, let transactionVersion, let period):
            return .polkadot(
                sequence: sequence,
                genesisHash: genesisHash,
                blockHash: blockHash,
                blockNumber: blockNumber,
                specVersion: specVersion,
                transactionVersion: transactionVersion,
                period: period
            )
        case .tron(let blockNumber, let blockVersion, let blockTimestamp, let transactionTreeRoot, let parentHash, let witnessAddress):
            return .tron(
                blockNumber: blockNumber,
                blockVersion: blockVersion,
                blockTimestamp: blockTimestamp,
                transactionTreeRoot: transactionTreeRoot,
                parentHash: parentHash,
                witnessAddress: witnessAddress
            )
        }
    }
}

extension Fee {
    public func map() -> Gemstone.GemTransactionLoadFee {
        return Gemstone.GemTransactionLoadFee(
            fee: fee.description,
            gasPrice: gasPrice.description,
            gasLimit: gasLimit.description,
            options: options.map()
        )
    }
}

extension GemTransactionLoadMetadata {
    public func map() throws -> TransactionLoadMetadata {
        switch self {
        case .none:
            return .none
        case .solana(let senderTokenAddress, let recipientTokenAddress, let tokenProgram, let sequence):
            return .solana(
                senderTokenAddress: senderTokenAddress,
                recipientTokenAddress: recipientTokenAddress,
                tokenProgram: tokenProgram.map(),
                sequence: sequence
            )
        case .ton(let jettonWalletAddress, let sequence):
            return .ton(jettonWalletAddress: jettonWalletAddress, sequence: sequence)
        case .cosmos(let accountNumber, let sequence, let chainId):
            return .cosmos(accountNumber: accountNumber, sequence: sequence, chainId: chainId)
        case .bitcoin(let utxos):
            return .bitcoin(utxos: try utxos.map { try $0.map() })
        case .cardano(let utxos):
            return .cardano(utxos: try utxos.map { try $0.map() })
        case .evm(let nonce, let chainId):
            return .evm(nonce: nonce, chainId: chainId)
        case .near(let sequence, let blockHash, let isDestinationAddressExist):
            return .near(sequence: sequence, blockHash: blockHash, isDestinationAddressExist: isDestinationAddressExist)
        case .stellar(let sequence, let isDestinationAddressExist):
            return .stellar(sequence: sequence, isDestinationAddressExist: isDestinationAddressExist)
        case .xrp(let sequence):
            return .xrp(sequence: sequence)
        case .algorand(let sequence):
            return .algorand(sequence: sequence)
        case .aptos(let sequence):
            return .aptos(sequence: sequence)
        case .polkadot(let sequence, let genesisHash, let blockHash, let blockNumber, let specVersion, let transactionVersion, let period):
            return .polkadot(
                sequence: sequence,
                genesisHash: genesisHash,
                blockHash: blockHash,
                blockNumber: blockNumber,
                specVersion: specVersion,
                transactionVersion: transactionVersion,
                period: period
            )
        case .tron(let blockNumber, let blockVersion, let blockTimestamp, let transactionTreeRoot, let parentHash, let witnessAddress):
            return .tron(
                blockNumber: blockNumber,
                blockVersion: blockVersion,
                blockTimestamp: blockTimestamp,
                transactionTreeRoot: transactionTreeRoot,
                parentHash: parentHash,
                witnessAddress: witnessAddress
            )
        }
    }
}

