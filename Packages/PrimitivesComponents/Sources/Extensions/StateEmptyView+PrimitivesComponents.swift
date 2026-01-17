// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import Localization

public extension StateEmptyView where Content == EmptyView {
    static func noData() -> StateEmptyView<EmptyView> {
        StateEmptyView(title: Localized.Common.notAvailable)
    }

    static func error(_ error: Error) -> StateEmptyView<EmptyView> {
        StateEmptyView(
            title: Localized.Errors.errorOccured,
            description: error.localizedDescription,
            image: Images.ErrorConent.error
        )
    }
}