// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public extension Binding where Value: Sendable {
    static func ??(lhs: Binding<Optional<Value>>, rhs: Value) -> Binding<Value> {
        Binding {
            lhs.wrappedValue ?? rhs
        } set: {
            lhs.wrappedValue = $0
        }
    }
}
