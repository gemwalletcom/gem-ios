// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

enum Predicate {
    case contains(String)
    case doesNotContain(String)
    case exists
    case doesNotExist
    case isHittable
    case isNotHittable

    var format: String {
        switch self {
        case .contains(let label): "label == '\(label)'"
        case .doesNotContain(let label): "label != '\(label)'"
        case .exists: "exists == true"
        case .doesNotExist: "exists == false"
        case .isHittable: "isHittable == true"
        case .isNotHittable: "isHittable == false"
        }
    }
}
