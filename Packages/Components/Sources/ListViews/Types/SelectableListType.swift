// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum SelectableListType<T: Sendable & Identifiable>: Sendable {
    case plain([T])
    case section([ListSection<T>])
    
    public var items: [T] {
        switch self {
        case .plain(let items):
            items
        case .section(let sections):
            sections.map { $0.values }.reduce([], +)
        }
    }
}
