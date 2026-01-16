// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import Localization
import Primitives

public extension StateEmptyView where Content == EmptyView {
    static func noData() -> StateEmptyView<EmptyView> {
        StateEmptyView(title: Localized.Common.notAvailable)
    }

    static func error(_ error: Error) -> StateEmptyView<EmptyView> {
        StateEmptyView(
            title: Localized.Errors.errorOccured,
            description: isNetworkError(error) ? error.localizedDescription : Localized.Errors.noDataAvailable,
            image: Images.ErrorConent.error
        )
    }
}