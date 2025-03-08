// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives

public struct ContactListViewItem: Identifiable {
    public let id: String
    let title: String
    let description: String?
    let contact: Contact
}
