// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

public protocol ValidatorConvertible {
    associatedtype T
    
    var errorMessage: String { get }
    func validate(_ value: T) throws
}
