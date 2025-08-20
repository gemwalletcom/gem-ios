// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension TransactionInput {
    public func map() -> GemTransactionLoadInput {
        GemTransactionLoadInput(
            inputType: self.type.map(),
            senderAddress: senderAddress,
            destinationAddress: destinationAddress,
            value: value.description,
            gasPrice: GemGasPrice(gasPrice: gasPrice.gasPrice.description),
            sequence: UInt64(preload.sequence),
            blockHash: preload.blockHash,
            blockNumber: Int64(preload.blockNumber),
            chainId: preload.chainId,
            utxos: preload.utxos.map { $0.map() }
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
            return .stake(operation: stakeType.mapToStakeOperation(asset: asset))
        case .deposit, .withdrawal, .transferNft, .tokenApprove, .account, .perpetual, .generic:
            fatalError("Unsupported transaction type: \(self)")
        }
    }
}

extension StakeType {
    public func mapToStakeOperation(asset: Asset) -> GemStakeOperation {
        switch self {
        case .stake(let validator):
            return .delegate(asset: asset.map(), validatorAddress: validator.id)
        case .unstake(let delegation):
            return .undelegate(asset: asset.map(), validatorAddress: delegation.validator.id)
        case .redelegate(let delegation, let toValidator):
            return .redelegate(asset: asset.map(), srcValidatorAddress: delegation.validator.id, dstValidatorAddress: toValidator.id)
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

