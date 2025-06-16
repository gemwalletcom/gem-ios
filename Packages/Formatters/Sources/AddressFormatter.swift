// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct AddressFormatter {
    public enum Style {
        case short
        case full
        case extra(Int)
    }
    
    private let style: Self.Style
    private let address: String
    private let chain: Chain?
    private let shownNumberOfCharacters = 5

    public init(
        style: Self.Style = .short,
        address: String,
        chain: Chain?
    ) {
        self.style = style
        self.address = address
        self.chain = chain
    }
    
    private var first: Int {
        guard let chain = chain else { return shownNumberOfCharacters }
        if let _ = EVMChain(rawValue: chain.rawValue) {
            return shownNumberOfCharacters + 2
        }
        switch chain {
        case .bitcoin,
            .aptos: return 6
        default:
            return shownNumberOfCharacters
        }
    }
    
    public func value() -> String {
        switch style {
        case .short: address.truncate(first: first, last: shownNumberOfCharacters)
        case .full: address
        case .extra(let extra): address.truncate(first: first + extra, last: shownNumberOfCharacters + extra)
        }
    }
}
