// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Combine
import Primitives

public final class SubscriptionsObserver {

    private let dbQueue: DatabaseQueue
    private var walletsObserver: AnyDatabaseCancellable?
    private let observation = ValueObservation.tracking(AccountRecord.fetchAll)
    private var walletsSubject = PassthroughSubject<[Account], Never>()
    private var count = 0
    
    public init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
        self.walletsObserver = observation.start(in: dbQueue, scheduling: .immediate) { error in

        } onChange: { value in
            //TODO: figure out how to set scheduling to update on changes without initial values
            self.count += 1
            if self.count > 1 {
                self.walletsSubject.send(value.map { $0.mapToAccount() })
            }
        }
    }
    
    public func observe() -> AnyPublisher<[Account], Never> {
        return walletsSubject.eraseToAnyPublisher()
    }
}
