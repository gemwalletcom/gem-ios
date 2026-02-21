// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Foundation
import Primitives
import PrimitivesTestKit
import StoreTestKit
import WalletConnectorServiceTestKit
import ConnectionsService
import ConnectionsServiceTestKit

@testable import WalletConnector
@testable import Store

struct ConnectionsViewModelTests {

    @Test @MainActor
    func sectionsOrderedByWalletOrder() {
        let connections: [WalletConnection] = [
            .mock(wallet: .mock(name: "Zebra", order: 2)),
            .mock(wallet: .mock(name: "Alpha", order: 1)),
            .mock(wallet: .mock(name: "Beta", order: 3))
        ]
        let model = ConnectionsViewModel(service: .mock())
        model.query.value = connections

        #expect(model.sections.count == 3)
        #expect(model.sections[0].title == "Alpha")
        #expect(model.sections[1].title == "Zebra")
        #expect(model.sections[2].title == "Beta")
    }

    @Test @MainActor
    func connectionsWithinSectionOrderedByCreatedDate() {
        let oldDate = Date(timeIntervalSince1970: 1000)
        let recentDate = Date(timeIntervalSince1970: 2000)
        let newestDate = Date(timeIntervalSince1970: 3000)

        let connections: [WalletConnection] = [
            .mock(session: .mock(createdAt: oldDate)),
            .mock(session: .mock(createdAt: newestDate)),
            .mock(session: .mock(createdAt: recentDate))
        ]
        let model = ConnectionsViewModel(service: .mock())
        model.query.value = connections

        #expect(model.sections.count == 1)
        #expect(model.sections[0].values.map { $0.session.createdAt } == [newestDate, recentDate, oldDate])
    }
}

extension ConnectionsService {
    static func mock() -> ConnectionsService {
        ConnectionsService(
            store: .mock(),
            signer: WalletConnectorSigner.mock(),
            connector: WalletConnectorServiceMock()
        )
    }
}
