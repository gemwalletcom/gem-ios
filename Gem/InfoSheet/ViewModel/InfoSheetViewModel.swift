// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
@preconcurrency import Gemstone
import GemstonePrimitives

struct InfoSheetViewModel {
    private let item: DocsUrl

    init(item: DocsUrl) {
        self.item = item
    }

    var url: URL {
        Docs.url(item)
    }

    var buttonTitle: String {
        "Learn more"
    }
}

// MARK: - InfoModel

extension InfoSheetViewModel: InfoModel {
    // TODO: - Now dummy text( need to implement Localization, need to know which is supported from doclist )
    // TODO: - Image ?
    var title: String {
        switch item {
        case .start: "Getting Started"
        case .whatIsWatchWallet: "Watch Wallet"
        case .whatIsSecretPhrase: "Secret Phrase"
        case .whatIsPrivateKey: "Private Key"
        case .howToSecureSecretPhrase: "Securing Your Phrase"
        case .transactionStatus: "Transaction Status"
        case .networkFees: "Network Fees"
        case .stakingLockTime: "Staking Lock Time"
        }
    }

    var description: String {
        switch item {
        case .start: "Learn how to set up your wallet and understand cryptocurrency basics."
        case .whatIsWatchWallet: "Monitor account balances and transactions without holding private keys."
        case .whatIsSecretPhrase: "A recovery phrase that grants access to your wallet. Keep it safe."
        case .whatIsPrivateKey: "A private key controls your assets. Keep it secret and secure."
        case .howToSecureSecretPhrase: "Store your phrase offline to protect your assets from digital threats."
        case .transactionStatus: "Track your transactions' status on the blockchain."
        case .networkFees: "Fees paid for transaction processing, varying by network conditions."
        case .stakingLockTime: "Tokens are locked for rewards and can't be moved during the period."
        }
    }

    var image: Image? {
        return Image(.logo)
    }
}
