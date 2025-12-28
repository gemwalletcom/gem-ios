// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum DeepLink: Sendable {

    static let host = "gemwallet.com"

    case asset(AssetId)
    case swap(AssetId, AssetId?)
    case perpetuals
    case rewards(code: String?)
    case gift(code: String?)
    case buy(AssetId, amount: Int?)
    case sell(AssetId, amount: Int?)
    case setPriceAlert(AssetId, price: Double?)

    public enum PathComponent: String {
        case tokens
        case swap
        case perpetuals
        case rewards
        case join
        case gift
        case buy
        case sell
        case setPriceAlert
    }

    public var pathComponent: PathComponent {
        switch self {
        case .asset: .tokens
        case .swap: .swap
        case .perpetuals: .perpetuals
        case .rewards: .rewards
        case .gift: .gift
        case .buy: .buy
        case .sell: .sell
        case .setPriceAlert: .setPriceAlert
        }
    }

    public var path: String {
        switch self {
        case .asset(let assetId):
            switch assetId.tokenId {
            case .some(let tokenId): "/\(pathComponent.rawValue)/\(assetId.chain.rawValue)/\(tokenId)"
            case .none: "/\(pathComponent.rawValue)/\(assetId.chain.rawValue)"
            }
        case let .swap(fromAssetId, toAssetId):
            switch toAssetId {
            case .some(let id): "/\(pathComponent.rawValue)/\(fromAssetId.identifier)/\(id.identifier)"
            case .none: "/\(pathComponent.rawValue)/\(fromAssetId.identifier)"
            }
        case .perpetuals: "/\(pathComponent.rawValue)"
        case .rewards(let code):
            switch code {
            case .some(let code): "/\(pathComponent.rawValue)?code=\(code)"
            case .none: "/\(pathComponent.rawValue)"
            }
        case .gift(let code):
            switch code {
            case .some(let code): "/\(pathComponent.rawValue)?code=\(code)"
            case .none: "/\(pathComponent.rawValue)"
            }
        case let .buy(assetId, amount), let .sell(assetId, amount):
            switch amount {
            case .some(let amount): "/\(pathComponent.rawValue)/\(assetId.identifier)?amount=\(amount)"
            case .none: "/\(pathComponent.rawValue)/\(assetId.identifier)"
            }
        case let .setPriceAlert(assetId, price):
            switch price {
            case .some(let price): "/\(pathComponent.rawValue)/\(assetId.identifier)?price=\(price)"
            case .none: "/\(pathComponent.rawValue)/\(assetId.identifier)"
            }
        }
    }

    public var url: URL {
        URL(string: "https://\(Self.host)\(path)")!
    }

    public var localUrl: URL {
        URL(string: "gem://\(path)")!
    }
}
