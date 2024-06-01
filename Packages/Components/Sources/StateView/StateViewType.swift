// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum StateViewType<T> {
    case noData
    case loading
    case loaded(T)
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
}
