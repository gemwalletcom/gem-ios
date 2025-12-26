// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public final class EventPresenterService: Sendable {

    @MainActor
    public var toastPresenter = ToastEventPresenter()

    public init() {}

    @MainActor
    public func present(_ event: ToastEvent) {
        toastPresenter.present(event)
    }
}
