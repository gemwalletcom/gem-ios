// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB

public extension ValueObservable {
    @MainActor
    func observe(
        in dbQueue: some DatabaseReader,
        onChange: @escaping @MainActor (Self.Value) -> Void
    ) -> DatabaseCancellable? {
        ValueObservation
            .tracking { try fetch($0) }
            .start(
                in: dbQueue,
                scheduling: .immediate,
                onError: { print("Observation error:", $0) },
                onChange: onChange
            )
    }
}
