// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Blockchain
import Foundation
import Primitives
import WalletCore

public struct TronSigner: Signable {
    
    func sign(
        input: SignerInput,
        contract: WalletCore.TronTransaction.OneOf_ContractOneof,
        feeLimit: Int?,
        privateKey: Data
    ) throws -> String {
        guard case .tron(let blockNumber, let blockVersion, let blockTimestamp, let transactionTreeRoot, let parentHash, let witnessAddress, _) = input.metadata else {
            throw AnyError("Missing ton metadata")
        }
        let signingInput = try TronSigningInput.with {
            $0.transaction = try TronTransaction.with {
                $0.contractOneof = contract
                $0.timestamp = Int64(blockTimestamp)
                $0.blockHeader = try TronBlockHeader.with {
                    $0.timestamp = Int64(blockTimestamp)
                    $0.number = Int64(blockNumber)
                    $0.version = Int32(blockVersion)
                    $0.txTrieRoot = try Data.from(hex: transactionTreeRoot)
                    $0.parentHash = try Data.from(hex: parentHash)
                    $0.witnessAddress = try Data.from(hex: witnessAddress)
                }
                if let feeLimit = feeLimit {
                    $0.feeLimit = Int64(feeLimit)
                }
                $0.expiration = Int64(blockTimestamp) + 10 * 60 * 60 * 1000
            }
            $0.privateKey = privateKey
        }
        let output: TronSigningOutput = AnySigner.sign(input: signingInput, coin: input.coinType)

        if !output.errorMessage.isEmpty {
            throw AnyError(output.errorMessage)
        }

        return output.json
    }
    
    private func createVoteWitnessContract(input: SignerInput, votes: [String: UInt64]) throws -> TronVoteWitnessContract {
        return TronVoteWitnessContract.with {
            $0.ownerAddress = input.senderAddress
            $0.support = true
            $0.votes = votes.map { address, count in
                TronVoteWitnessContract.Vote.with {
                    $0.voteAddress = address
                    $0.voteCount = Int64(count)
                }
            }
        }
    }
    
    public func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        let contract = TronTransferContract.with {
            $0.ownerAddress = input.senderAddress
            $0.toAddress = input.destinationAddress
            $0.amount = input.value.asInt64
        }
        return try sign(input: input, contract: .transfer(contract), feeLimit: .none, privateKey: privateKey)
    }

    public func signTokenTransfer(input: SignerInput, privateKey: Data) throws -> String {
        let contract = try TronTransferTRC20Contract.with {
            $0.contractAddress = try input.asset.getTokenId()
            $0.ownerAddress = input.senderAddress
            $0.toAddress = input.destinationAddress
            $0.amount = input.value.magnitude.serialize()
        }
        return try sign(input: input, contract: .transferTrc20Contract(contract), feeLimit: input.fee.gasPrice.asInt, privateKey: privateKey)
    }

    public func signStake(input: SignerInput, privateKey: Data) throws -> [String] {
        guard case let .stake(_, stakeType) = input.type else {
            throw (AnyError("Invalid input type for staking"))
        }

        let contract: WalletCore.TronTransaction.OneOf_ContractOneof
        switch stakeType {
        case .stake:
            let freezeContract = TronFreezeBalanceV2Contract.with {
                $0.ownerAddress = input.senderAddress
                $0.frozenBalance = input.value.asInt64
                $0.resource = "BANDWIDTH" // Or "ENERGY"
            }

            let voteContract = try createVoteWitnessContract(input: input, votes: input.metadata.getVotes())
            return try [
                sign(input: input, contract: .freezeBalanceV2(freezeContract), feeLimit: .none, privateKey: privateKey),
                sign(input: input, contract: .voteWitness(voteContract), feeLimit: .none, privateKey: privateKey)
            ]
        case .unstake:
            let votes = try input.metadata.getVotes()
            if votes.isEmpty {
                contract = .unfreezeBalanceV2(TronUnfreezeBalanceV2Contract.with {
                    $0.ownerAddress = input.senderAddress
                    $0.unfreezeBalance = input.value.asInt64
                    $0.resource = "BANDWIDTH" // Or "ENERGY"
                })
            } else {
                let unfreezeContract = TronUnfreezeBalanceV2Contract.with {
                    $0.ownerAddress = input.senderAddress
                    $0.unfreezeBalance = input.value.asInt64
                    $0.resource = "BANDWIDTH" // Or "ENERGY"
                }
                let voteContract = try createVoteWitnessContract(input: input, votes: votes)
                return try [
                    sign(input: input, contract: .unfreezeBalanceV2(unfreezeContract), feeLimit: .none, privateKey: privateKey),
                    sign(input: input, contract: .voteWitness(voteContract), feeLimit: .none, privateKey: privateKey)
                ]
            }
        case .redelegate:
            let votes = try input.metadata.getVotes()
            contract = .voteWitness(try createVoteWitnessContract(input: input, votes: votes))
        case .rewards:
            contract = .withdrawBalance(TronWithdrawBalanceContract.with {
                $0.ownerAddress = input.senderAddress
            })
        case .withdraw:
            contract = .withdrawExpireUnfreeze(TronWithdrawExpireUnfreezeContract.with {
                $0.ownerAddress = input.senderAddress
            })
        }
        return try [
            sign(input: input, contract: contract, feeLimit: .none, privateKey: privateKey)
        ]
    }

    public func signSwap(input: SignerInput, privateKey: Data) throws -> [String] {
//        guard
//            case let .swap(_, _, _quoteData) = input.type,
//            //let data = Data(fromHex: quoteData.data.data),
//            //let callValue = Int64(quoteData.data.value)
//        else {
//            throw AnyError("Invalid input type for swapping")
//        }
        throw AnyError.notImplemented
    }
}
