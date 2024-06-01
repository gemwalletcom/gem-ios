// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone

extension Config {
    public static let shared = Config()
}

public struct Docs {
    public static func url(_ item: Gemstone.DocsUrl) -> URL {
        return URL(string: Config.shared.getDocsUrl(item: item))!
    }
}

public struct Social {
    public static func url(_ item: Gemstone.SocialUrl) -> URL {
        return URL(string: Config.shared.getSocialUrl(item: item))!
    }
}

public struct PublicConstants {
    public static func url(_ item: Gemstone.PublicUrl) -> URL {
        return URL(string: Config.shared.getPublicUrl(item: item))!
    }
}
