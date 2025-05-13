// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Components
import Primitives
import Localization

public struct MessagePreviewViewModel {
    
    private let message: MessagePreview
    
    public init(message: MessagePreview) {
        self.message = message
    }
    
    var messageDisplayType: SignMessageDisplayType {
        switch message {
        case .text(let text): return .text(text)
        case .eip712(let message):
            let sections = [
                ListSection(
                    id: message.domain.verifyingContract,
                    title: Localized.WalletConnect.domain,
                    image: nil,
                    values: [
                        KeyValueItem(title: Localized.Wallet.name, value: message.domain.name),
                        KeyValueItem(title: Localized.Asset.contract, value: message.domain.verifyingContract)
                    ]
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
        }
    }
}
