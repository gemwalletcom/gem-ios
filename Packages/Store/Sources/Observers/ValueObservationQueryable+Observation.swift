// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDBQuery
import GRDB

public extension ValueObservationQueryable {
    @MainActor
    func observe(
        in context: DatabaseContext,
        onChange: @escaping @MainActor (Self.Value) -> Void
    ) -> DatabaseCancellable? {
        let observation = ValueObservation.tracking { db in
            try fetch(db)
        }

        do {
            return observation.start(
                in: try context.reader,
                scheduling: .immediate,
                onError: { print("Observation error:", $0) },
                onChange: onChange
            )
        } catch {
            print("Failed to start observation:", error)
            return nil
        }
    }
}
