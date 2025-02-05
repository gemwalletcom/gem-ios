// Copyright (c). Gem Wallet. All rights reserved.


import Foundation
import Gemstone
import Primitives

extension AssetLink {
    public var socialUrl: SocialUrl? {
        switch name.lowercased() {
        case "x": .x
        case "x (formerly twitter)": .x
        case "discord": .discord
        case "reddit": .reddit
        case "telegram": .telegram
        case "youtube": .youTube
        case "facebook": .facebook
        case "website": .website
        case "coingecko": .coingecko
        case "github": .gitHub
        default: .none
        }
    }
    
    public func host(for social: SocialUrl?) -> String? {
        switch social {
        case .website: cleanHost(host: url)
        case .x,
            .discord,
            .telegram,
            .gitHub,
            .youTube,
            .reddit,
            .facebook,
            .coingecko: nil
        case .none:
            nil
        }
    }
    
    private func cleanHost(host: String?) -> String? {
        guard let host else { return host}
        let values = ["www.", "https://", "http://"]
        for value in values {
            if host.hasPrefix(value) {
                return host.replacingOccurrences(of: value, with: "")
            }
        }
        return host
    }
}
