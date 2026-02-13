// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI

struct OnChangeBindQueryModifier<Q: DatabaseQueryable>: ViewModifier where Q.Value: Equatable {
    @Environment(\.database) private var database

    let query: ObservableQuery<Q>
    let initial: Bool
    let action: ((Q.Value, Q.Value) -> Void)

    init(
        query: ObservableQuery<Q>,
        initial: Bool = false,
        action: @escaping ((Q.Value, Q.Value) -> Void)
    ) {
        self.query = query
        self.initial = initial
        self.action = action
    }

    func body(content: Content) -> some View {
        content
            .onAppear {
                query.bind(dbQueue: database.dbQueue)
            }
            .onChange(
                of: query.value,
                initial: initial
            ) { oldValue, newValue in
                action(oldValue, newValue)
            }
    }
}

public extension View {
    func onChangeBindQuery<Q: DatabaseQueryable>(
        _ query: ObservableQuery<Q>,
        initial: Bool = false,
        action: @escaping ((Q.Value, Q.Value) -> Void)
    ) -> some View where Q.Value: Equatable {
        modifier(
            OnChangeBindQueryModifier(
                query: query,
                initial: initial,
                action: action
            )
        )
    }
}
