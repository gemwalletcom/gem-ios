// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import StoreTestKit
import Preferences
import PreferencesTestKit
import WalletConnectorService
import WalletConnectorServiceTestKit
@testable import ConnectionsService

public extension ConnectionsService {
    static func mock(
        store: ConnectionsStore = .mock(),
        signer: any WalletConnectorSignable = WalletConnectorSignableMock(),
        connector: WalletConnectorServiceable = WalletConnectorServiceMock(),
        preferences: Preferences = .mock()
    ) -> ConnectionsService {
        ConnectionsService(
            store: store,
            signer: signer,
            connector: connector,
            preferences: preferences
        )
    }
}
