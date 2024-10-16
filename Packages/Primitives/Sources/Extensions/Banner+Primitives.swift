// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension Banner: Identifiable {
    public var id: String {
        [wallet?.id, asset?.id.identifier, event.rawValue].compactMap { $0 }.joined(separator: "_")
    }
}

extension Banner {
    public var closeOnAction: Bool {
        switch event {
        case .stake, .accountActivation: false
        case .enableNotifications: true
        }
    }
}
