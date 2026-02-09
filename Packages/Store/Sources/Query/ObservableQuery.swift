// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Combine
import Primitives

@Observable
@MainActor
public final class ObservableQuery<Request: DatabaseQueryable>: Sendable, BindableQuery {

    public var request: Request {
        didSet {
            guard request != oldValue else { return }
            startObservation()
        }
    }

    public private(set) var value: Request.Value

    private var db: DatabaseQueue?
    private var cancellable: AnyCancellable?

    public init(_ request: Request) {
        self.request = request
        self.value = Request.defaultValue
    }

    public func bind(db: DatabaseQueue) {
        guard self.db == nil else { return }
        self.db = db
        startObservation()
    }

    private func startObservation() {
        guard let db else { return }

        cancellable = ValueObservation.tracking { [request] db in
            try request.fetch(db)
        }
        .publisher(in: db, scheduling: .immediate)
        .sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    debugLog("ObservableQuery<\(Request.self)> error: \(error)")
                }
            },
            receiveValue: { [weak self] newValue in
                self?.value = newValue
            }
        )
    }
}
