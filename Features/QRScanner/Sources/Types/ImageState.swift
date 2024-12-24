// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

enum ImageState: Equatable {
    case empty
    case success(UIImage)
    case failure(Error)

    static func == (lhs: ImageState, rhs: ImageState) -> Bool {
        switch (lhs, rhs) {
        case (.empty, .empty):
            return true
        case (.success(let lhsImage), .success(let rhsImage)):
            return lhsImage.hashValue == rhsImage.hashValue
        case (.failure(let lhsError), .failure(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}
