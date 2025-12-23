// Copyright (c). Gem Wallet. All rights reserved.

import Components
import Primitives
import PrimitivesComponents

struct AmountResourceViewModel {
    private let type: AmountType
    private let selectedResource: Primitives.Resource

    init(type: AmountType, selectedResource: Primitives.Resource) {
        self.type = type
        self.selectedResource = selectedResource
    }

    var showResource: Bool {
        switch type {
        case .freeze: true
        case .transfer, .deposit, .withdraw, .perpetual, .stake, .stakeRedelegate, .stakeUnstake, .stakeWithdraw: false
        }
    }

    var resources: [ResourceViewModel] {
        [.bandwidth, .energy].map { ResourceViewModel(resource: $0) }
    }

    var freezeRecipient: Recipient {
        let resourceTitle = ResourceViewModel(resource: selectedResource).title
        return Recipient(name: resourceTitle, address: resourceTitle, memo: nil)
    }

    static func defaultResource(for type: AmountType) -> Primitives.Resource {
        guard case .freeze(let data) = type else { return .bandwidth }
        return data.resource
    }
}

// MARK: - ItemModelProvidable

extension AmountResourceViewModel: ItemModelProvidable {
    var itemModel: AmountItemModel {
        guard showResource else { return .empty }
        return .resource(AmountResourceItemModel(resources: resources))
    }
}
