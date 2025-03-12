// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import GRDBQuery

struct OnChangeQueryObserverModifier<Q: ValueObservationQueryable>: ViewModifier where Q.Value: Equatable, Q.Context == DatabaseContext {
    @Binding private var value: Q.Value
    @Binding private var request: Q

    private let initial: Bool
    private let action: ((Q.Value, Q.Value) -> Void)

    init(
        request: Binding<Q>,
        value: Binding<Q.Value>,
        initial: Bool = false,
        action: @escaping ((Q.Value, Q.Value) -> Void)
    ) {
        _value = value
        _request = request
        self.initial = initial
        self.action = action
    }

    func body(content: Content) -> some View {
        content
            .observeQuery(
                request: $request,
                value: $value
            )
            .onChange(
                of: value,
                initial: initial
            ) { oldValue, newValue in
                action(oldValue, newValue)
            }
    }
}

public extension View {
    func onChangeObserveQuery<Q: ValueObservationQueryable>(
        request: Binding<Q>,
        value: Binding<Q.Value>,
        initial: Bool = false,
        action: @escaping ((Q.Value, Q.Value) -> Void)
    ) -> some View where Q.Value: Equatable, Q.Context == DatabaseContext {
        modifier(
            OnChangeQueryObserverModifier(
                request: request,
                value: value,
                initial: initial,
                action: action
            )
        )
    }
}
