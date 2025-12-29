// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style

@Observable
public final class ToastEventPresenter: Sendable {
    @MainActor
    public var toastMessage: ToastMessage?

    public init() {}

    @MainActor
    public func present(_ event: ToastEvent) {
        toastMessage = ToastEventMessageFactory.makeToastMessage(for: event)
    }
}
