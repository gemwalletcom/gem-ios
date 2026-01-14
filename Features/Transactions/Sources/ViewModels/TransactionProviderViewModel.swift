// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesComponents
import Localization
import Components
import class Gemstone.SwapProviderConfig

public struct TransactionProviderViewModel: Sendable {
    private let metadata: TransactionSwapMetadata?

    public init(metadata: TransactionSwapMetadata?) {
        self.metadata = metadata
    }
}

extension TransactionProviderViewModel: ItemModelProvidable {
    public var itemModel: TransactionItemModel {
        guard let providerId = metadata?.provider else {
            return .empty
        }

        return .listItem(
            .text(
                title: Localized.Common.provider,
                subtitle: SwapProviderConfig.fromString(id: providerId).inner().name
            )
        )
    }
}
