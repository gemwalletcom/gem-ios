// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum StateViewType<T: Sendable>: Sendable {
    case noData
    case loading
    case data(T)
    case error(Error)
    
    public var isLoading: Bool {
        switch self {
        case .loading: true
        default: false
        }
    }
    
    public var isNoData: Bool {
        switch self {
        case .noData: true
        default: false
        }
    }

    public var isError: Bool {
        switch self {
        case .error: true
        default: false
        }
    }

    public var value: T? {
        guard case .data(let t) = self else {
            return nil
        }
        return t
    }
    
    public func map<U: Sendable>(_ transform: (T) -> U) -> StateViewType<U> {
        switch self {
        case .noData: .noData
        case .loading: .loading
        case .data(let value): .data(transform(value))
        case .error(let error): .error(error)
        }
    }
}
