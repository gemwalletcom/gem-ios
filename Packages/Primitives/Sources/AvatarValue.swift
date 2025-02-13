// Copyright (c). Gem Wallet. All rights reserved.
import Foundation

public struct AvatarValue: Codable, Hashable {
    public let url: URL
    
    public init(url: URL) {
        self.url = url
    }
}
