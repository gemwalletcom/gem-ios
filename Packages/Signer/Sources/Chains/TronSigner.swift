// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Blockchain
import Foundation
import Primitives
import WalletCore
import WalletCorePrimitives

public struct TronSigner: Signable {
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
            guard case let .vote(votes) = input.extra else {
                throw (AnyError("vote for stacking should be always set"))
            }
            let freezeContract = TronFreezeBalanceV2Contract.with {
                $0.ownerAddress = input.senderAddress
                $0.frozenBalance = input.value.asInt64
                $0.resource = "BANDWIDTH" // Or "ENERGY"
            }

            let voteContract = TronVoteWitnessContract.with {
                $0.ownerAddress = input.senderAddress
                $0.support = true
                $0.votes = votes.map { adress, count in
                    TronVoteWitnessContract.Vote.with {
                        $0.voteAddress = adress
                        $0.voteCount = Int64(count)
                    }
                }
            }
            return try [
                sign(input: input, contract: .freezeBalanceV2(freezeContract), feeLimit: .none, privateKey: privateKey),
                sign(input: input, contract: .voteWitness(voteContract), feeLimit: .none, privateKey: privateKey)
            ]
        case .unstake:
            guard case let .vote(votes) = input.extra else {
                throw (AnyError("vote for stacking should be always set"))
            }
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
                let voteContract = TronVoteWitnessContract.with {
                    $0.ownerAddress = input.senderAddress
                    $0.support = true
                    $0.votes = votes.map { adress, count in
                        TronVoteWitnessContract.Vote.with {
                            $0.voteAddress = adress
                            $0.voteCount = Int64(count)
                        }
                    }
                }
                return try [
                    sign(input: input, contract: .unfreezeBalanceV2(unfreezeContract), feeLimit: .none, privateKey: privateKey),
                    sign(input: input, contract: .voteWitness(voteContract), feeLimit: .none, privateKey: privateKey)
                ]
            }
        case .redelegate:
            guard case let .vote(votes) = input.extra else {
                throw (AnyError("vote for stacking should be always set"))
            }
            contract = .voteWitness(TronVoteWitnessContract.with {
                $0.ownerAddress = input.senderAddress
                $0.support = true
                $0.votes = votes.map { adress, count in
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
        return try [
            sign(input: input, contract: contract, feeLimit: .none, privateKey: privateKey)
        ]
    }

    public func signSwap(input: SignerInput, privateKey: Data) throws -> [String] {
        guard
            case let .swap(_, _, quote, quoteData) = input.type,
            let quoteData,
            let data = Data(fromHex: quoteData.data),
            let callValue = Int64(quoteData.value),
            let gasLimit = quoteData.gasLimit
        else {
            throw AnyError("Invalid input type for swapping")
        }

        let contract = TronTriggerSmartContract.with {
            $0.ownerAddress = quote.request.walletAddress
            $0.contractAddress = quoteData.to
            $0.data = data
            $0.callValue = callValue
        }

        if let approval = quoteData.approval {
            guard let spender = WalletCore.Base58.decodeNoCheck(string: approval.spender)?.dropFirst() else {
                throw AnyError("Invalid spender address")
            }

            let callData = EthereumAbi.approve(spender: spender, value: .MAX_256)
            let approvalContract = TronTriggerSmartContract.with {
                $0.ownerAddress = quote.request.walletAddress
                $0.contractAddress = approval.token
                $0.data = callData
            }

            let swapFee = BigInt(stringLiteral: gasLimit) * input.fee.gasPrice

            return try [
                sign(input: input, contract: .triggerSmartContract(approvalContract), feeLimit: Int(input.fee.fee), privateKey: privateKey),
                sign(input: input, contract: .triggerSmartContract(contract), feeLimit: Int(swapFee), privateKey: privateKey)
            ]
        } else {
            return try [
                sign(input: input, contract: .triggerSmartContract(contract), feeLimit: Int(input.fee.fee), privateKey: privateKey)
            ]
        }
    }
}

// MARK: - Private

extension TronSigner {
    func sign(
        input: SignerInput,
        contract: WalletCore.TronTransaction.OneOf_ContractOneof,
        feeLimit: Int?,
        privateKey: Data
    ) throws -> String {
        let block = input.block
        let transactionTreeRoot = try Data.from(hex: block.transactionTreeRoot)
        let parentHash = try Data.from(hex: block.parentHash)
        let witnessAddress = try Data.from(hex: block.witnessAddress)

        let signingInput = TronSigningInput.with {
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
        let output: TronSigningOutput = AnySigner.sign(input: signingInput, coin: input.coinType)

        if !output.errorMessage.isEmpty {
            throw AnyError(output.errorMessage)
        }

        return output.json
    }
}
