// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import WalletCorePrimitives
import Blockchain
import Primitives
import BigInt

public struct TronSigner: Signable {
    public func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        let contract = TronTransferContract.with {
            $0.ownerAddress = input.senderAddress
            $0.toAddress = input.destinationAddress
            $0.amount = input.value.asInt64
        }
        let signingInput = try prepareSigningInput(block: input.block, contract: .transfer(contract), feeLimit: .none, privateKey: privateKey)
        let output: TronSigningOutput = AnySigner.sign(input: signingInput, coin: input.coinType)
        return output.json
    }
    
    public func signTokenTransfer(input: SignerInput, privateKey: Data) throws -> String {
        let contract = TronTransferTRC20Contract.with {
            $0.contractAddress = input.asset.tokenId!
            $0.ownerAddress = input.senderAddress
            $0.toAddress = input.destinationAddress
            $0.amount = input.value.magnitude.serialize()
        }
        let signingInput = try prepareSigningInput(block: input.block, contract: .transferTrc20Contract(contract), feeLimit: input.fee.gasPrice.asInt, privateKey: privateKey)
        let output: TronSigningOutput = AnySigner.sign(input: signingInput, coin: input.coinType)
        return output.json
    }
    
    public func signData(input: Primitives.SignerInput, privateKey: Data) throws -> String {
        fatalError()
    }
    
    public func swap(input: SignerInput, privateKey: Data) throws -> String {
        fatalError()
    }

    public func signMessage(message: SignMessage, privateKey: Data) throws -> String {
        fatalError()
    }

    public func signStake(input: SignerInput, privateKey: Data) throws -> [String] {
        guard case let .stake(_, stakeType) = input.type else {
            throw(AnyError("Invalid input type for staking"))
        }

        let contract: WalletCore.TronTransaction.OneOf_ContractOneof
        switch stakeType {
        case .stake:
            guard case let .vote(votes) = input.extra else {
                throw(AnyError("vote for stacking should be always set"))
            }
            let freezeContract = TronFreezeBalanceV2Contract.with {
                $0.ownerAddress = input.senderAddress
                $0.frozenBalance = input.value.asInt64
                $0.resource = "BANDWIDTH"  // Or "ENERGY"
            }

            let voteContract = TronVoteWitnessContract.with {
                $0.ownerAddress = input.senderAddress
                $0.support = true
                $0.votes = votes.map { (adress, count) in
                    TronVoteWitnessContract.Vote.with {
                        $0.voteAddress = adress
                        $0.voteCount = Int64(count)
                    }
                }
            }
            let freezeInput = try prepareSigningInput(block: input.block, contract: .freezeBalanceV2(freezeContract), feeLimit: .none, privateKey: privateKey)
            let voteInput = try prepareSigningInput(block: input.block, contract: .voteWitness(voteContract), feeLimit: .none, privateKey: privateKey)
            let freezeOutput: TronSigningOutput = AnySigner.sign(input: freezeInput, coin: input.coinType)
            let voteOutput: TronSigningOutput = AnySigner.sign(input: voteInput, coin: input.coinType)

            return [freezeOutput.json, voteOutput.json]
        case .unstake:
            guard case let .vote(votes) = input.extra else {
                throw(AnyError("vote for stacking should be always set"))
            }
            if votes.isEmpty {
                contract = .unfreezeBalanceV2(TronUnfreezeBalanceV2Contract.with {
                    $0.ownerAddress = input.senderAddress
                    $0.unfreezeBalance = input.value.asInt64
                    $0.resource = "BANDWIDTH"  // Or "ENERGY"
                })
            } else {
                let unfreezeContract = TronUnfreezeBalanceV2Contract.with {
                    $0.ownerAddress = input.senderAddress
                    $0.unfreezeBalance = input.value.asInt64
                    $0.resource = "BANDWIDTH"  // Or "ENERGY"
                }
                let voteContract = TronVoteWitnessContract.with {
                    $0.ownerAddress = input.senderAddress
                    $0.support = true
                    $0.votes = votes.map { (adress, count) in
                        TronVoteWitnessContract.Vote.with {
                            $0.voteAddress = adress
                            $0.voteCount = Int64(count)
                        }
                    }
                }

                let unfreezeInput = try prepareSigningInput(block: input.block, contract: .unfreezeBalanceV2(unfreezeContract), feeLimit: .none, privateKey: privateKey)
                let voteInput = try prepareSigningInput(block: input.block, contract: .voteWitness(voteContract), feeLimit: .none, privateKey: privateKey)
                let unfreezeOutput: TronSigningOutput = AnySigner.sign(input: unfreezeInput, coin: input.coinType)
                let voteOutput: TronSigningOutput = AnySigner.sign(input: voteInput, coin: input.coinType)
                
                return [unfreezeOutput.json, voteOutput.json]
            }
        case .redelegate:
            guard case let .vote(votes) = input.extra else {
                throw(AnyError("vote for stacking should be always set"))
            }
            contract = .voteWitness(TronVoteWitnessContract.with {
                $0.ownerAddress = input.senderAddress
                $0.support = true
                $0.votes = votes.map { (adress, count) in
                    TronVoteWitnessContract.Vote.with {
                        $0.voteAddress = adress
                        $0.voteCount = Int64(count)
                    }
                }
            })
        case .rewards:
            contract = .withdrawBalance(TronWithdrawBalanceContract.with {
                $0.ownerAddress = input.senderAddress
            })
        case .withdraw:
            contract = .withdrawExpireUnfreeze(TronWithdrawExpireUnfreezeContract.with {
                $0.ownerAddress = input.senderAddress
            })
        }
        let signingInput = try prepareSigningInput(block: input.block, contract: contract, feeLimit: .none, privateKey: privateKey)
        let output: TronSigningOutput = AnySigner.sign(input: signingInput, coin: input.coinType)
        return [output.json]
    }
}

// MARK: - Private

extension TronSigner {
    func prepareSigningInput(
        block: SignerInputBlock,
        contract: WalletCore.TronTransaction.OneOf_ContractOneof,
        feeLimit: Int?,
        privateKey: Data
    ) throws -> TronSigningInput {
        let transactionTreeRoot = try Data.from(hex: block.transactionTreeRoot)
        let parentHash = try Data.from(hex: block.parentHash)
        let witnessAddress = try Data.from(hex: block.witnessAddress)

        return TronSigningInput.with {
            $0.transaction = TronTransaction.with {
                $0.contractOneof = contract
                $0.timestamp = Int64(block.timestamp)
                $0.blockHeader = TronBlockHeader.with {
                    $0.timestamp = Int64(block.timestamp)
                    $0.number = Int64(block.number)
                    $0.version = Int32(block.version)
                    $0.txTrieRoot = transactionTreeRoot
                    $0.parentHash = parentHash
                    $0.witnessAddress = witnessAddress
                }
                if let feeLimit = feeLimit {
                    $0.feeLimit = Int64(feeLimit)
                }
                $0.expiration = Int64(block.timestamp) + 10 * 60 * 60 * 1000
            }
            $0.privateKey = privateKey
        }
    }
}
