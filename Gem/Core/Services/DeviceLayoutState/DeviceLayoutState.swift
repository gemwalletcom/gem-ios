// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

@Observable
class DeviceLayoutState {
    public static let shared = DeviceLayoutState()

    private var idiom: UIUserInterfaceIdiom
    public var layout: DeviceLayout

    init() {
        self.idiom = UIDevice.current.userInterfaceIdiom
        self.layout = DeviceLayout(size: .zero, safeArea: .init(), sizeClass: .none, orientation: .current)
    }

    public var isDeviceiPhone: Bool { idiom == .phone }
    public var isDeviceiPad: Bool { idiom == .pad }
    public var isCompactStyle: Bool {
        isDeviceiPhone || !isDeviceiPhone && layout.sizeClass == .compact
    }
}
