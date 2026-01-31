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

struct ConnectionsViewModelTests {
    
    @Test @MainActor
    func sectionsOrderedByWalletOrder() {
        let model = ConnectionsViewModel(service: .mock())
        model.connections = [
            WalletConnection(session: .mock(), wallet: .mock(name: "Zebra", order: 2)),
            WalletConnection(session: .mock(), wallet: .mock(name: "Alpha", order: 1)),
            WalletConnection(session: .mock(), wallet: .mock(name: "Beta", order: 3))
        ]
        
        let sections = model.sections
        
        #expect(sections.count == 3)
        #expect(sections[0].title == "Alpha")
        #expect(sections[1].title == "Zebra")
        #expect(sections[2].title == "Beta")
    }
    
    @Test @MainActor
    func connectionsWithinSectionOrderedByCreatedDate() {
        let oldDate = Date(timeIntervalSince1970: 1000)
        let recentDate = Date(timeIntervalSince1970: 2000)
        let newestDate = Date(timeIntervalSince1970: 3000)
        
        let model = ConnectionsViewModel(service: .mock())
        model.connections = [
            WalletConnection(session: .mock(createdAt: oldDate), wallet: .mock()),
            WalletConnection(session: .mock(createdAt: newestDate), wallet: .mock()),
            WalletConnection(session: .mock(createdAt: recentDate), wallet: .mock())
        ]
        
        let sections = model.sections
        
        #expect(sections.count == 1)
        #expect(sections[0].values.map { $0.session.createdAt } == [newestDate, recentDate, oldDate])
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