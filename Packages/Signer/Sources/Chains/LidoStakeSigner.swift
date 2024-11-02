// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import WalletCorePrimitives
import BigInt
import Keystore
import Primitives
import Blockchain
import Gemstone

public class LidoStakeSigner: EthereumSigner {
    override public func signStake(input: SignerInput, privateKey: Data) throws -> String {
        guard let stakeType = input.type.stakeType else {
            throw AnyError("Invalid stake type")
        }

        let valueData: Data = switch stakeType {
        case .stake:
            input.value.magnitude.serialize()
        case .unstake, .withdraw:
            Data()
        case .rewards, .redelegate:
            fatalError()
        }

        let signatureData: Data = try {
            switch stakeType {
            case .unstake:
                guard case .lidoPermitNonce(let permitNonce) = input.extra else {
                    throw AnyError("Permit nonce is missing!")
                }
                let permit = ERC2612PermitMessage(
                    message: ERC2612Permit(
                        owner: input.senderAddress,
                        spender: LidoContract.withdrawal,
                        value: input.value.description,
                        nonce: permitNonce,
                        deadline: "\(LidoContract.permitDeadline(date: Date()))"
                    ), 
                    chainId: UInt32(input.chainId)!)
                let jsonString = String(data: try JSONEncoder().encode(permit), encoding: .utf8)!
                let signature = try self.signMessage(
                    message: .typed(jsonString),
                    privateKey: privateKey
                )
                return Data(hexString: signature) ?? Data()
            default:
                return Data()
            }
        }()

        let callData = try LidoContract.encodeStake(type: stakeType, sender: input.senderAddress, amount: input.value, signature: signatureData)
        let data = try sign(coinType: input.coinType, input: buildBaseInput(
            input: input,
            transaction: .with {
                $0.contractGeneric = EthereumTransaction.ContractGeneric.with {
                    $0.amount = valueData
                    $0.data = callData
                }
            },
            toAddress: input.destinationAddress,
            privateKey: privateKey
        ))
        return data
    }
}
