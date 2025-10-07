// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum HeaderButtonType: String, Identifiable, CaseIterable, Sendable {
    case send
    case receive
    case buy
    case sell
    case swap
    case stake
    case more
    case deposit
    case withdraw
    
    public var id: String { rawValue }
}
