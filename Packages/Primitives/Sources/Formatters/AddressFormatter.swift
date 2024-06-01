// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct AddressFormatter {
    
    public enum Style {
        case short
        case full
        case extra(Int)
    }
    
    private let style: Self.Style
    private let address: String
    private let chain: Chain?
    private let firstDefault = 4

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
        guard let chain = chain else { return firstDefault }
        if let _ = EVMChain(rawValue: chain.rawValue) {
            return 6
        }
        switch chain {
        case .bitcoin,
            .aptos:
            return 6
        default:
            return firstDefault
        }
    }
    
    public func value() -> String {
        switch style {
        case .short:
            return address.truncate(first: first, last: 4)
        case .full:
            return address
        case .extra(let extra):
            return address.truncate(first: first + extra, last: 4 + extra)
        }
    }
}
