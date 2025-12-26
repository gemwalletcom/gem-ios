// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public final class EventManager: Sendable {

    @MainActor
    public var toastPresenter = ToastEventPresenter()

    public init() {}

    @MainActor
    public func send(_ event: AppEvent) {
        switch event.presentationType {
        case .toast: toastPresenter.present(event)
        }
    }
}
