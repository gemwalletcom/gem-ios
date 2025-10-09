// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore
import Primitives
import Signer

import class Gemstone.Config
import struct Gemstone.Permit2ApprovalData
import struct Gemstone.Permit2Data
import func Gemstone.permit2DataToEip712Json
import struct Gemstone.Permit2Detail
import struct Gemstone.PermitSingle

protocol Permit2DataProvidable: Sendable {
    func getPermit2Data(
        wallet: Wallet,
        chain: Chain,
        approval: Permit2ApprovalData
    ) throws -> Permit2Data
}

struct Permit2DataProvider: Permit2DataProvidable {
    private let keystore: any Keystore

    init(keystore: some Keystore) {
        self.keystore = keystore
    }

    func getPermit2Data(
        wallet: Wallet,
        chain: Chain,
        approval: Permit2ApprovalData
    ) throws -> Permit2Data {

        let permitSingle = permitSingle(approval: approval)
        let json = try Gemstone.permit2DataToEip712Json(
            chain: chain.rawValue,
            data: permitSingle,
            contract: approval.permit2Contract
        )

        let signer = Signer(wallet: wallet, keystore: keystore)
        let hexSignature = try signer.signMessage(chain: chain, message: .typed(json))
        let signature = try Data.from(hex: hexSignature)

        return Permit2Data(permitSingle: permitSingle, signature: signature)
    }
}

// MARK: - Private

extension Permit2DataProvider {
    private func permitSingle(approval: Permit2ApprovalData) -> PermitSingle {
        let config = Config.shared.getSwapConfig()
        let now = Date().timeIntervalSince1970
        return PermitSingle(
            details: Permit2Detail(
                token: approval.token,
                amount: approval.value,
                expiration: UInt64(now) + config.permit2Expiration,
                nonce: approval.permit2Nonce
            ),
            spender: approval.spender,
            sigDeadline: UInt64(now) + config.permit2SigDeadline
        )
    }
}
