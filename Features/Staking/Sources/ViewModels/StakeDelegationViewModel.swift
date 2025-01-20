// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components
import SwiftUI
import Style
import Preferences
import ExplorerService
import GemstonePrimitives

public struct StakeDelegationViewModel {
    
    public let delegation: Delegation
    private let formatter = ValueFormatter(style: .medium)
    private let validatorImageFormatter = AssetImageFormatter()
    private let exploreService: ExplorerService = .standart

    private static let dateFormatterDefault: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour]
        formatter.zeroFormattingBehavior = .dropLeading
        formatter.unitsStyle = .full
        return formatter
    }()
    
    private static let dateFormatterDay: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.zeroFormattingBehavior = .dropLeading
        formatter.unitsStyle = .full
        return formatter
    }()
    
    public init(delegation: Delegation) {
        self.delegation = delegation
    }
    
    private var asset: Asset {
        delegation.base.assetId.chain.asset
    }
    
    public var state: DelegationState {
        delegation.base.state
    }
    
    public var stateText: String {
        delegation.base.state.title
    }
    
    public var stateTextColor: Color {
        switch state {
        case .active:
            Colors.green
        case .pending,
            .undelegating,
            .activating,
            .deactivating:
            Colors.orange
        case .inactive,
            .awaitingWithdrawal:
            Colors.red
        }
    }
    
    public var balanceText: String {
        formatter.string(delegation.base.balanceValue, decimals: asset.decimals.asInt, currency: asset.symbol)
    }
    
    public var rewardsText: String? {
        switch delegation.base.state {
        case .active:
            // hide 0 rewards
            if delegation.base.rewardsValue == 0 {
                return .none
            }
            return formatter.string(delegation.base.rewardsValue, decimals: asset.decimals.asInt, currency: asset.symbol)
        case .pending,
            .undelegating,
            .inactive,
            .activating,
            .deactivating,
            .awaitingWithdrawal:
            return .none
        }
    }
    
    public var balanceTextStyle: TextStyle {
        .body
    }
    
    public var validatorText: String {
        if delegation.validator.name.isEmpty {
            return AddressFormatter(style: .short, address: delegation.validator.id, chain: asset.chain).value()
        }
        return delegation.validator.name
    }
    
    public var validatorImageUrl: URL? {
        validatorImageFormatter.getValidatorUrl(chain: asset.chain, id: delegation.validator.id)
    }
    
    public var validatorUrl: URL? {
        exploreService.validatorUrl(chain: asset.chain, address: delegation.validator.id)?.url
    }
    
    public var completionDateText: String? {
        let now = Date.now
        if let completionDate = delegation.base.completionDate, completionDate > now {
            if now.distance(to: completionDate) < 86400 { // 1 day
                return Self.dateFormatterDay.string(from: .now, to: completionDate)
            }
            return Self.dateFormatterDefault.string(from: .now, to: completionDate)
        }
        return .none
    }
}

extension StakeDelegationViewModel: Identifiable {
    public var id: String { delegation.id }
}
