// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import Primitives
import PrimitivesComponents

@Observable
public final class FreezeAmountTypeViewModel: AmountTypeConfigurable {
    public typealias Item = Resource
    public typealias ItemViewModel = ResourceViewModel

    private var freezeData: FreezeData

    public var selectedItem: Resource? {
        didSet {
            if let selectedItem {
                freezeData = freezeData.with(resource: selectedItem)
            }
        }
    }

    public init(freezeData: FreezeData) {
        self.freezeData = freezeData
        self.selectedItem = freezeData.resource
    }

    public var items: [Resource] { [.bandwidth, .energy] }

    public var defaultItem: Resource? { freezeData.resource }

    public var selectedItemViewModel: ResourceViewModel? {
        selectedItem.map { ResourceViewModel(resource: $0) }
    }

    public var isSelectionEnabled: Bool { true }

    public var selectionTitle: String { Localized.Stake.resource }

    public var freezeType: FreezeType { freezeData.freezeType }

    public var currentFreezeData: FreezeData { freezeData }

    public func pickerItems() -> [ResourceViewModel] {
        items.map { ResourceViewModel(resource: $0) }
    }
}
