// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import GRDBQuery

struct QueryObserverModifier<Q: ValueObservationQueryable>: ViewModifier where Q.Value: Equatable, Q.Context == DatabaseContext {
    @Query<Q> private var queryValue: Q.Value
    @Binding private var value: Q.Value

    init(request: Binding<Q>, value: Binding<Q.Value>) {
        _value = value
        _queryValue = Query(request)
    }

    func body(content: Content) -> some View {
        content
            .onChange(
                of: queryValue,
                initial: true
            ) { _, newValue in
                value = newValue
            }
    }
}

public extension View {
    func observeQuery<Q: ValueObservationQueryable>(
        request: Binding<Q>,
        value: Binding<Q.Value>
    ) -> some View where Q.Value: Equatable, Q.Context == DatabaseContext {
        modifier(
            QueryObserverModifier(
                request: request,
                value: value
            )
        )
    }
}
