// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Gemstone

struct StakeRecommendedValidators {
    
    private var list: [Chain: Set<String>] {
        var output: [Chain: Set<String>] = [:]
        Config().getValidators().forEach { (key, values) in
            if let chain = Chain(rawValue: key) {
                output[chain] = Set(values)
            }
        }
        return output
    }
    
    func randomValidatorId(chain: Chain) -> String? {
        list[chain]?.randomElement()
    }
    
    func validatorsSet(chain: Chain) -> Set<String> {
        list[chain] ?? Set()
    }
}
