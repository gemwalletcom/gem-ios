// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Foundation
import Primitives
import SwiftHTTPClient
import WalletCore

public struct OptimismGasOracle: Sendable {
    // https://optimistic.etherscan.io/address/0x420000000000000000000000000000000000000F#readProxyContract
    // https://basescan.org/address/0x420000000000000000000000000000000000000F#readProxyContract
    // https://opbnbscan.com/address/0x420000000000000000000000000000000000000F?p=1&tab=Contract
    static let contract = "0x420000000000000000000000000000000000000F"
    // v,r,s
    static let signatureLenInRlp = 67 // 1 + 32 + 1 + 32 + 1
    
    let chain: EVMChain
    let provider: Provider<EthereumTarget>
    let service: EthereumService
    
    public init(
        chain: EVMChain,
        provider: Provider<EthereumTarget>
    ) {
        self.chain = chain
        self.provider = provider
        self.service = EthereumService(chain: chain, provider: provider)
    }

    func getL1Fee(data: Data) async throws -> BigInt {
        let fn = EthereumAbiFunction(name: "getL1Fee")
        fn.addParamBytes(val: data, isOutput: false)
        let data = EthereumAbi.encode(fn: fn)
        return try await call(data: data)
            .map(as: JSONRPCResponse<BigIntable>.self).result.value
    }
    
    func call(data: Data) async throws -> Response {
        let params = [
            "to": Self.contract,
            "data": data.hexString.append0x,
        ]
        return try await provider.request(.call(params))
    }
}

extension OptimismGasOracle {
    public func fee(input: FeeInput) async throws -> Fee {
        // https://github.com/ethereum-optimism/optimism/blob/develop/packages/fee-estimation/src/estimateFees.ts#L230
        let data = try service.getData(input: input)
        let to = try service.getTo(input: input)
        
        async let getGasLimit = try service.getGasLimit(
            from: input.senderAddress,
            to: to,
            value: service.getValue(input: input)?.hexString.append0x,
            data: data?.hexString.append0x
        )
        async let getNonce = try service.getNonce(senderAddress: input.senderAddress)
        async let getChainId = try service.getChainId()
        
        let (gasLimit, nonce, chainId) = try await (getGasLimit, getNonce, getChainId)
        let priorityFee = EthereumService.getPriorityFeeByType(input.type, isMaxAmount: input.isMaxAmount, gasPriceType: input.gasPrice)

        let value = {
            switch input.type {
            case .transfer(let asset):
                asset.type == .native && input.isMaxAmount ? input.balance - gasLimit * input.gasPrice.gasPrice : input.value
            case .transferNft, .generic, .swap, .tokenApprove:
                input.value
            case .stake, .account: fatalError()
            }
        }()
        
        let encoded = try getEncodedData(
            gasLimit: gasLimit,
            gasPrice: input.gasPrice.gasPrice,
            priorityFee: input.gasPrice.priorityFee,
            nonce: nonce,
            callData: data ?? Data(),
            feeInput: input,
            chainId: chainId,
            value: value
        )
        
        let l2fee = input.gasPrice.totalFee * gasLimit
        let l1fee = try await getL1Fee(data: encoded)

        return Fee(
            fee: l1fee + l2fee,
            gasPriceType: .eip1559(gasPrice: input.gasPrice.totalFee, priorityFee: priorityFee),
            gasLimit: gasLimit
        )
    }
    
    private func getEncodedData(
        gasLimit: BigInt,
        gasPrice: BigInt,
        priorityFee: BigInt,
        nonce: Int,
        callData: Data,
        feeInput: FeeInput,
        chainId: Int,
        value: BigInt
    ) throws -> Data {
        let input = try EthereumSigningInput.with {
            $0.chainID = BigInt(chainId).magnitude.serialize()
            $0.txMode = .enveloped
            $0.nonce = BigInt(nonce).magnitude.serialize()
            $0.toAddress = try service.getTo(input: feeInput)
            $0.transaction = WalletCore.EthereumTransaction.with {
                $0.contractGeneric = WalletCore.EthereumTransaction.ContractGeneric.with {
                    $0.amount = value.magnitude.serialize()
                    $0.data = callData
                }
            }
            $0.gasLimit = gasLimit.magnitude.serialize()
            $0.maxFeePerGas = gasPrice.magnitude.serialize()
            $0.maxInclusionFeePerGas = priorityFee.magnitude.serialize()
            $0.privateKey = PrivateKey().data
        }
        
        let signed: EthereumSigningOutput = AnySigner.sign(input: input, coin: feeInput.chain.coinType)
        var encoded = signed.encoded.dropLast(Self.signatureLenInRlp)
        
        switch feeInput.type {
        case .transfer(let asset):
            switch asset.id.type {
            case .native:
                // not 100% accurate without RLP decoding (0x02f8740a...)
                // remove 1 more byte at index 2 since length changed
                encoded.remove(at: 2)
            default:
                break
            }
        case .generic, .swap, .tokenApprove:
            break
        case .transferNft, .stake, .account:
            fatalError()
        }
        
        return encoded
    }
}
