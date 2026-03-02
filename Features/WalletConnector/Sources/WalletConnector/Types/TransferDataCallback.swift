// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import os

public final class TransferDataCallback<T: Identifiable & Sendable>: Sendable, Identifiable {
    public typealias ConfirmTransferDelegate = @Sendable (Result<String, any Error>) -> Void
    public typealias ConfirmMessageDelegate = @Sendable (Result<String, any Error>) -> Void

    public let payload: T
    public let delegate: ConfirmTransferDelegate

    public init(
        payload: T,
        delegate: @escaping ConfirmTransferDelegate
    ) {
        self.payload = payload
        let wasCalled = OSAllocatedUnfairLock(initialState: false)
        self.delegate = { result in
            let isFirstCall = wasCalled.withLock { wasCalled in
                defer { wasCalled = true }
                return !wasCalled
            }
            guard isFirstCall else { return }
            delegate(result)
        }
    }

    public var id: any Hashable { payload.id }
}
