// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization

public extension Error {
    var networkOrNoDataDescription: String {
        isNetworkError(self) ? localizedDescription : Localized.Errors.noDataAvailable
    }
}
