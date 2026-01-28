// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesComponents
import Localization
import Components
import class Gemstone.SwapProviderConfig

struct TransactionProviderViewModel: Sendable {
    private let metadata: TransactionSwapMetadata?

    init(metadata: TransactionSwapMetadata?) {
        self.metadata = metadata
    }
}

extension TransactionProviderViewModel: ItemModelProvidable {
    var itemModel: TransactionItemModel {
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
