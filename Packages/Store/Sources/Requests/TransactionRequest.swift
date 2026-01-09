// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct TransactionRequest: ValueObservationQueryable {
    public static var defaultValue: TransactionExtended { .empty }

    private let walletId: WalletId
    private let transactionId: String

    public var filters: [TransactionsRequestFilter] = []

    public init(
        walletId: WalletId,
        transactionId: String
    ) {
        self.walletId = walletId
        self.transactionId = transactionId
    }

    public func fetch(_ db: Database) throws -> TransactionExtended {
        try TransactionsRequest.fetch(
            db,
            type: .transaction(id: transactionId),
            filters: filters,
            walletId: walletId,
            limit: 1
        ).first ?? .empty
    }
}

extension TransactionExtended {
    public static let empty: TransactionExtended = {
        let asset: Asset = Asset(
            id: AssetId(chain: .bitcoin, tokenId: nil),
            name: "",
            symbol: "",
            decimals: 0,
            type: .native
        )

        return TransactionExtended(
            transaction: Transaction(
                id: TransactionId(chain: .ethereum, hash: ""),
                assetId: AssetId(chain: .bitcoin, tokenId: nil),
                from: "",
                to: "",
                contract: nil,
                type: .transfer,
                state: .pending,
                blockNumber: "",
                sequence: "",
                fee: "",
                feeAssetId: AssetId(chain: .bitcoin, tokenId: nil),
                value: "",
                memo: nil,
                direction: .selfTransfer,
                utxoInputs: [],
                utxoOutputs: [],
                metadata: nil,
                createdAt: .now
            ),
            asset: asset,
            feeAsset: asset,
            price: nil,
            feePrice: nil,
            assets: [],
            prices: [],
            fromAddress: nil,
            toAddress: nil
        )
    }()
}

