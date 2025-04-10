// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Style
import Components

struct SecurityReminderItem: Identifiable {
    var id: String { [title,subtitle].joined() }

    let title: String
    let subtitle: String
    let image: ListItemImageStyle?
}

extension SecurityReminderItem {
    static let createWallet: [Self] = [
        SecurityReminderItem(
            title: "Do Not Share It With Anyone",
            subtitle: "Anyone who has your secret phrase can access your wallet from anywhere in the world.",
            image: .security(Images.System.exclamationmarkTriangle)
        ),
        SecurityReminderItem(
            title: "Keep Your Secret Phrase Safe",
            subtitle: "Store it somewhere safe, the phrase is only way to access your wallet.",
            image: .security(Images.System.pencilLine)
        ),
        SecurityReminderItem(
            title: "If you lose it, we cannot recover it.",
            subtitle: "Its created only for you. Gem Wallet does not keep copy of your phrase.",
            image: .security(Images.Logo.icon)
        )
    ]
}
