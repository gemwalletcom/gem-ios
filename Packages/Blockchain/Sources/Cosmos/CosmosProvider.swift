// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftHTTPClient

public enum CosmosProvider: TargetType {
    case balance(address: String)
    case account(address: String)
    case delegations(address: String)
    case undelegations(address: String)
    case rewards(address: String)
    case validators
    case block(String)
    case broadcast(data: String)
    case transaction(id: String)
    case syncing
    
    public var baseUrl: URL {
        return URL(string: "")!
    }
    
    public var method: HTTPMethod {
        switch self {
        case .balance,
            .account,
            .block,
            .transaction,
            .syncing,
            .delegations,
            .undelegations,
            .rewards,
            .validators:
            return .GET
        case .broadcast:
            return .POST
        }
    }
    
    public var path: String {
        switch self {
        case .balance(let address):
            return "/cosmos/bank/v1beta1/balances/\(address)"
        case .account(let address):
            return "/cosmos/auth/v1beta1/accounts/\(address)"
        case .delegations(address: let address):
            return "/cosmos/staking/v1beta1/delegations/\(address)"
        case .undelegations(address: let address):
            return "/cosmos/staking/v1beta1/delegators/\(address)/unbonding_delegations"
        case .rewards(address: let address):
            return "/cosmos/distribution/v1beta1/delegators/\(address)/rewards"
        case .validators:
            return "/cosmos/staking/v1beta1/validators?pagination.limit=1000"
        case .block(let block):
            return "/cosmos/base/tendermint/v1beta1/blocks/\(block)"
        case .broadcast:
            return "/cosmos/tx/v1beta1/txs"
        case .transaction(let id):
            return "/cosmos/tx/v1beta1/txs/\(id)"
        case .syncing:
            return "/cosmos/base/tendermint/v1beta1/syncing"
        }
    }
    
    public var task: Task {
        switch self {
        case .balance,
            .account,
            .delegations,
            .undelegations,
            .rewards,
            .validators,
            .block,
            .transaction,
            .syncing:
            return .plain
        case .broadcast(let data):
            return .data(Data(data.utf8))
        }
    }
    
    public var contentType: String {
        return ContentType.json.rawValue
    }
}
