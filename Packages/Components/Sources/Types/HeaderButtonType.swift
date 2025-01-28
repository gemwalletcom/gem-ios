// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum HeaderButtonType: String, Identifiable, CaseIterable, Sendable {
    case send
    case receive
    case buy
    case swap
    case more
    
    public var id: String { rawValue }
}
