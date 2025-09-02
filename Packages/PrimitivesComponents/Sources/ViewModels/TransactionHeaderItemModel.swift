// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import Localization

public struct TransactionHeaderItemModel {
    public let headerType: TransactionHeaderType
    public let headerLink: URL?
    
    public init(transaction: TransactionExtended, infoModel: TransactionInfoViewModel) {
        let metadata: TransactionExtendedMetadata? = {
            guard let metadata = transaction.transaction.metadata else {
                return nil
            }
            return TransactionExtendedMetadata(
                assets: transaction.assets,
                assetPrices: transaction.prices,
                transactionMetadata: metadata
            )
        }()
        
        self.headerType = TransactionHeaderTypeBuilder.build(
            infoModel: infoModel,
            transaction: transaction.transaction,
            metadata: metadata
        )
        
        self.headerLink = Self.getHeaderLink(for: transaction.transaction)
    }
    
    public var showClearHeader: Bool {
        switch headerType {
        case .amount, .nft: true
        case .swap: false
        }
    }
    
    public var showSwapAgain: Bool {
        switch headerType {
        case .amount, .nft: false
        case .swap: true
        }
    }
    
    public var swapAgainText: String {
        Localized.Transaction.swapAgain
    }
    
    @MainActor
    public func onSelectHeader() {
        if let headerLink {
            UIApplication.shared.open(headerLink)
        }
    }
    
    private static func getHeaderLink(for transaction: Primitives.Transaction) -> URL? {
        switch transaction.metadata {
        case .null, .nft, .none, .perpetual: 
            nil
        case let .swap(metadata): 
            DeepLink.swap(metadata.fromAsset, metadata.toAsset).localUrl
        }
    }
}