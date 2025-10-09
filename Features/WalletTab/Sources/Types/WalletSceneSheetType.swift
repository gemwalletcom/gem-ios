// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import InfoSheet
import Primitives
import SwiftUI

public enum WalletSceneSheetType: Identifiable, Sendable {
    case wallets
    case selectAssetType(SelectAssetType)
    case info(InfoSheetType)
    case url(URL)
    case transferData(TransferData)
    case perpetualRecipientData(PerpetualRecipientData)
    case setPriceAlert(AssetId)

    public var id: String {
        switch self {
        case .wallets: "wallets"
        case let .selectAssetType(type): "select-asset-type-\(type.id)"
        case let .info(type): "info-\(type.id)"
        case let .url(url): "url-\(url)"
        case let .transferData(data): "transfer-data-\(data.id)"
        case let .perpetualRecipientData(data): "perpetual-recipient-data-\(data.id)"
        case let .setPriceAlert(assetId): "set-price-alert-\(assetId.identifier)"
        }
    }
}

// MARK: - Binding extensions

extension Binding where Value == WalletSceneSheetType? {
    public var selectAssetType: Binding<SelectAssetType?> {
        Binding<SelectAssetType?>(
            get: {
                if case .selectAssetType(let type) = wrappedValue {
                    return type
                }
                return nil
            },
            set: { newValue in
                wrappedValue = newValue.map { .selectAssetType($0) }
            }
        )
    }

    public var transferData: Binding<TransferData?> {
        Binding<TransferData?>(
            get: {
                if case .transferData(let data) = wrappedValue {
                    return data
                }
                return nil
            },
            set: { newValue in
                wrappedValue = newValue.map { .transferData($0) }
            }
        )
    }

    public var perpetualRecipientData: Binding<PerpetualRecipientData?> {
        Binding<PerpetualRecipientData?>(
            get: {
                if case .perpetualRecipientData(let data) = wrappedValue {
                    return data
                }
                return nil
            },
            set: { newValue in
                wrappedValue = newValue.map { .perpetualRecipientData($0) }
            }
        )
    }

    public var wallets: Binding<Bool> {
        Binding<Bool>(
            get: {
                if case .wallets = wrappedValue { return true }
                return false
            },
            set: { newValue in
                wrappedValue = newValue ? .wallets : nil
            }
        )
    }

    public var setPriceAlert: Binding<AssetId?> {
        Binding<AssetId?>(
            get: {
                if case .setPriceAlert(let assetId) = wrappedValue {
                    return assetId
                }
                return nil
            },
            set: { newValue in
                wrappedValue = newValue.map { .setPriceAlert($0) }
            }
        )
    }
}
