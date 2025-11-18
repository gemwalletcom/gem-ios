// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives
import Localization
import enum Gemstone.MessagePreview

public struct MessagePreviewViewModel {
    
    private let message: MessagePreview
    
    public init(message: MessagePreview) {
        self.message = message
    }
    
    var messageDisplayType: SignMessageDisplayType {
        switch message {
        case .text(let text): return .text(text)
        case .eip712(let message):
            let domainValues = [KeyValueItem(title: Localized.Wallet.name, value: message.domain.name)]
                + (message.domain.verifyingContract.map { [KeyValueItem(title: Localized.Asset.contract, value: $0)] } ?? [])

            let sections = [
                ListSection(
                    id: message.domain.verifyingContract ?? message.domain.name,
                    title: Localized.WalletConnect.domain,
                    image: nil,
                    values: domainValues
                )
            ] +
            message.message.map {
                ListSection(
                    id: $0.name,
                    title: $0.name,
                    image: nil,
                    values: $0.values.map { KeyValueItem(title: $0.name, value: $0.value) }.filter { $0.title.isNotEmpty && $0.value.isNotEmpty }
                )
            }
            return .sections(sections)
        case .siwe(let message):
            return .siwe(message)
        }
    }
}
