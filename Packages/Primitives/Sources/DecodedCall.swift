// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct DecodedCall: Equatable, Sendable, Hashable {
    public let method: ContractMethod?
    public let recipient: String?
    public let amount: String?
    
    public init(
        method: ContractMethod?,
        recipient: String? = nil,
        amount: String? = nil
    ) {
        self.method = method
        self.recipient = recipient
        self.amount = amount
    }
}

public enum ContractMethod: String, Equatable, Sendable, Hashable {
    case transfer
    
    public var recipientField: String? {
        switch self {
        case .transfer: "to"
        }
    }
    
    public var amountField: String? {
        switch self {
        case .transfer: "value"
        }
    }
}
