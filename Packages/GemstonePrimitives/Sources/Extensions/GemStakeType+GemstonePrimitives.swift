// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives
import BigInt

extension GemFreezeData {
    public func map() throws -> FreezeData {
        return FreezeData(
            freezeType: try freezeType.map(),
            resource: try resource.map()
        )
    }
}

extension FreezeData {
    public func map() -> GemFreezeData {
        return GemFreezeData(
            freezeType: freezeType.map(),
            resource: resource.map()
        )
    }
}

extension GemFreezeType {
    public func map() throws -> FreezeType {
        switch self {
        case .freeze: .freeze
        case .unfreeze: .unfreeze
        }
    }
}

extension FreezeType {
    public func map() -> GemFreezeType {
        switch self {
        case .freeze: .freeze
        case .unfreeze: .unfreeze
        }
    }
}

extension GemResource {
    public func map() throws -> Resource {
        switch self {
        case .bandwidth: .bandwidth
        case .energy: .energy
        }
    }
}

extension Resource {
    public func map() -> GemResource {
        switch self {
        case .bandwidth: .bandwidth
        case .energy: .energy
        }
    }
}

extension GemStakeType {
    public func map() throws -> StakeType {
        switch self {
        case .delegate(let validator):
            return .stake(try validator.map())
        case .undelegate(let delegation):
            return .unstake(try delegation.map())
        case .redelegate(let delegation, let toValidator):
            return .redelegate(RedelegateData(delegation: try delegation.map(), toValidator: try toValidator.map()))
        case .withdrawRewards(let validators):
            let mappedValidators = try validators.map { try $0.map() }
            return .rewards(mappedValidators)
        case .withdraw(let delegation):
            return .withdraw(try delegation.map())
        case .freeze(let freezeData):
            return .freeze(try freezeData.map())
        }
    }
}

extension StakeType {
    public func map() -> GemStakeType {
        switch self {
        case .stake(let validator):
            return .delegate(validator: validator.map())
        case .unstake(let delegation):
            return .undelegate(delegation: delegation.map())
        case .redelegate(let data):
            return .redelegate(delegation: data.delegation.map(), toValidator: data.toValidator.map())
        case .rewards(let validators):
            return .withdrawRewards(validators: validators.map { $0.map() })
        case .withdraw(let delegation):
            return .withdraw(delegation: delegation.map())
        case .freeze(let data):
            return .freeze(freezeData: data.map())
        }
    }
}
