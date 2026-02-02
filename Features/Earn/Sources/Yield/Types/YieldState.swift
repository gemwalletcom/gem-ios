// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum YieldState: Sendable {
    case idle
    case loading
    case loaded([YieldProtocolViewModel], YieldPositionViewModel?)
    case error(Error)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var protocols: [YieldProtocolViewModel] {
        if case .loaded(let yields, _) = self { return yields }
        return []
    }

    var position: YieldPositionViewModel? {
        if case .loaded(_, let position) = self { return position }
        return nil
    }

    var error: Error? {
        if case .error(let error) = self { return error }
        return nil
    }

    var hasError: Bool {
        error != nil
    }
}
