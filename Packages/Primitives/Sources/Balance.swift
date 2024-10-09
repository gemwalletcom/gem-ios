import Foundation
import BigInt

public struct Balance: Codable, Sendable {

    public var available: BigInt
    public var frozen: BigInt
    public var locked: BigInt
    public var staked: BigInt
    public var pending: BigInt
    public var rewards: BigInt
    public var reserved: BigInt

    public init(
        available: BigInt,
        frozen: BigInt = .zero,
        locked: BigInt = .zero,
        staked: BigInt = .zero,
        pending: BigInt = .zero,
        rewards: BigInt = .zero,
        reserved: BigInt = .zero
    ) {
        self.available = available
        self.frozen = frozen
        self.locked = locked
        self.staked = staked
        self.pending = pending
        self.rewards = rewards
        self.reserved = reserved
    }
}

public extension Balance {
    func merge(_ balance: Balance) -> Balance {
        return Self(
            available: self.available + balance.available,
            frozen: self.frozen + balance.frozen,
            locked: self.locked + balance.locked,
            staked: self.staked + balance.staked,
            pending: self.pending + balance.pending,
            rewards: self.rewards + balance.rewards,
            reserved: self.reserved + balance.reserved
        )
    }
}
