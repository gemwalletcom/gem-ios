// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import GRDB

public struct DatabaseAccess: Sendable {
    private let _dbQueue: DatabaseQueue?

    public static let notConfigured = DatabaseAccess(nil)

    public init(_ dbQueue: DatabaseQueue?) {
        self._dbQueue = dbQueue
    }

    public var dbQueue: DatabaseQueue {
        guard let _dbQueue else {
            fatalError("DatabaseQueue not configured. Use .databaseQueue() modifier.")
        }
        return _dbQueue
    }
}

private struct DatabaseQueueKey: EnvironmentKey {
    static let defaultValue: DatabaseAccess = .notConfigured
}

public extension EnvironmentValues {
    var database: DatabaseAccess {
        get { self[DatabaseQueueKey.self] }
        set { self[DatabaseQueueKey.self] = newValue }
    }
}

public extension View {
    func databaseQueue(_ dbQueue: DatabaseQueue) -> some View {
        environment(\.database, DatabaseAccess(dbQueue))
    }
}
