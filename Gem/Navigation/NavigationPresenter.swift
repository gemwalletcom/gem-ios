// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives

@Observable
final class NavigationPresenter: Sendable {
    @MainActor private var _isPresentingAssetInput: SelectedAssetInput?
    @MainActor private var _isPresentingPriceAlert: SetPriceAlertInput?
    @MainActor private var _isPresentingSupport: Bool = false

    init() {}
}

@MainActor
extension NavigationPresenter {
    var isPresentingAssetInput: Binding<SelectedAssetInput?> {
        Binding(get: { self._isPresentingAssetInput }, set: { self._isPresentingAssetInput = $0 })
    }

    var isPresentingPriceAlert: Binding<SetPriceAlertInput?> {
        Binding(get: { self._isPresentingPriceAlert }, set: { self._isPresentingPriceAlert = $0 })
    }

    var isPresentingSupport: Binding<Bool> {
        Binding(get: { self._isPresentingSupport }, set: { self._isPresentingSupport = $0 })
    }
}
