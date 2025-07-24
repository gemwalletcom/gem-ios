// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemAPI
import Preferences

public struct ScanService: Sendable {
    private let apiService: any GemAPIScanService
    private let securePreferences: SecurePreferences

    public init(
        apiService: any GemAPIScanService = GemAPIService(),
        securePreferences: SecurePreferences
    ) {
        self.apiService = apiService
        self.securePreferences = securePreferences
    }

    public func getScanTransaction(_ payload: ScanTransactionPayload) async throws -> ScanTransaction {
        try await apiService.getScanTransaction(payload: payload)
    }

    public func getTransactionPayload(wallet: Wallet, transferType: TransferDataType, recipient: RecipientData) throws -> ScanTransactionPayload {
        let chain = transferType.chain
        let origin = ScanAddressTarget(
            chain: chain,
            address: try wallet.account(for: chain).address
        )
        let target = switch transferType {
        case .swap(_, let toAsset, _):
            ScanAddressTarget(chain: toAsset.chain, address: try wallet.account(for: toAsset.chain).address)
        default :
            ScanAddressTarget(chain: chain, address: recipient.recipient.address)
        }

        return ScanTransactionPayload(
            deviceId: try securePreferences.getDeviceId(),
            walletIndex: UInt32(wallet.index),
            origin: origin,
            target: target,
            website: .none,
            type: transferType.transactionType
        )
    }
}
