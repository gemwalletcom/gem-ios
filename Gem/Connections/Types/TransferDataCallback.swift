// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

final class TransferDataCallback<T: Identifiable & Sendable>: Sendable, Identifiable {
    typealias ConfirmTransferDelegate = @Sendable (Result<String, any Error>) -> Void
    typealias ConfirmMessageDelegate = @Sendable (Result<String, any Error>) -> Void

    let payload: T
    let delegate: ConfirmTransferDelegate

    init(
        payload: T,
        delegate: @escaping ConfirmTransferDelegate
    ) {
        self.payload = payload
        self.delegate = delegate
    }
    var id: any Hashable { payload.id }
}
