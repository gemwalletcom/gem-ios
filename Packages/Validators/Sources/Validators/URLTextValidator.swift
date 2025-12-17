// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import Primitives

public struct URLTextValidator: TextValidator {
    public init() {}

    public func validate(_ text: String) throws {
        guard let url = try? URLDecoder().decode(text),
              let host = url.host, host.contains(".") else {
            throw URLValidationError.invalidUrl
        }
    }

    public var id: String { "url" }
}

public extension TextValidator where Self == URLTextValidator {
    static var url: Self { .init() }
}
