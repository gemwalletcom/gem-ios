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

    public func scanTransaction(_ payload: ScanTransactionPayload) async throws -> ScanTransaction {
        try await apiService.getScanTransaction(payload: payload)
    }

    public func validate(_ payload: ScanTransactionPayload) async throws {
        do {
            let transaction = try await scanTransaction(payload)

            if transaction.isMalicious {
                throw ScanError.malicious
            }

            if payload.type == .transfer, transaction.isMemoRequired {
                throw ScanError.memoRequired(chain: payload.target.chain)
            }
        } catch {
            // For swap transactions, re-throw the error. For all other types, an error
            // from scanTransaction is ignored, and the transaction is considered valid.
            if payload.type == .swap {
                throw error
            }
        }
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
