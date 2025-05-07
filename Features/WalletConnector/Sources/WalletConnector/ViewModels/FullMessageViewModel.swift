// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

struct FullMessageViewModel {
    let message: String
    
    var displayMessage: String {
        prettify(jsonString: message) ?? message
    }
    
    func prettify(jsonString: String) -> String? {
        if let data = jsonString.data(using: .utf8),
           let object = try? JSONSerialization.jsonObject(with: data),
           let prettyData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            return prettyString
        }
        return nil
    }
}
