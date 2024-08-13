// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

// MARK: - Enviroment

extension DeviceLayoutState {
    struct Key: EnvironmentKey {
        static var defaultValue: DeviceLayoutState { DeviceLayoutState.shared }
    }
}

extension EnvironmentValues {
    var deviceLayoutState: DeviceLayoutState {
        get { self[DeviceLayoutState.Key.self] }
        set { self[DeviceLayoutState.Key.self] = newValue }
    }
}

// MARK: - Preference

extension DeviceLayoutState {
    struct DeviceLayoutPreferenceKey: PreferenceKey {
        static var defaultValue = DeviceLayout(
            size: .zero,
            safeArea: .init(),
            sizeClass: .none,
            orientation: .unknown
        )

        static func reduce(value: inout DeviceLayout, nextValue: () -> DeviceLayout) {
            value = nextValue()
        }
    }
}

// MARK: - View Modifier

extension DeviceLayoutState {
    struct ObserverViewModifier: ViewModifier {
        @Environment(\.deviceLayoutState) private var deviceLayoutState
        @Environment(\.horizontalSizeClass) private var horizontalSizeClass

        func body(content: Content) -> some View {
            ZStack {
                content
                GeometryReader { proxy in
                    Color.clear
                        .preference(
                            key: DeviceLayoutPreferenceKey.self,
                            value: DeviceLayout(
                                size: proxy.size,
                                safeArea: proxy.safeAreaInsets,
                                sizeClass: horizontalSizeClass,
                                orientation: .current
                            )
                        )
                }
            }
            .onPreferenceChange(DeviceLayoutPreferenceKey.self) { newValue in
                deviceLayoutState.layout = newValue
            }
        }
    }
}

extension View {
    func observeDeviceLayout() -> some View {
        modifier(DeviceLayoutState.ObserverViewModifier())
    }
}
