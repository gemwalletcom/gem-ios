// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

@Observable
@MainActor
final class NavigationPathState {
    private var stack: [AnyHashable] = []
    private(set) var path = NavigationPath() {
        didSet {
            if stack.count > path.count {
                stack = Array(stack.prefix(path.count))
            }
        }
    }

    var binding: Binding<NavigationPath> {
        Binding(
            get: { self.path },
            set: { self.path = $0 }
        )
    }

    var count: Int { path.count }
    var isEmpty: Bool { path.isEmpty }

    @discardableResult
    func append<T: Hashable>(_ value: T) -> Bool {
        let wrapped = AnyHashable(value)
        if stack.last == wrapped {
            return false
        }
        stack.append(wrapped)
        path.append(value)
        return true
    }

    func setPath(_ items: [any Hashable]) {
        stack = items.map { AnyHashable($0) }
        path = items.reduce(into: NavigationPath()) { $0.append($1) }
    }

    func reset() {
        guard !path.isEmpty else { return }
        path.removeLast(path.count)
    }

    func removeLast(_ k: Int = 1) {
        path.removeLast(k)
    }
}
