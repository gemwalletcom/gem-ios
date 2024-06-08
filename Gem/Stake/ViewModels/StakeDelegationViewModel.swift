// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt
import Components
import SwiftUI
import Style
import GemstoneSwift

struct StakeDelegationViewModel {
    let delegation: Delegation
    
    private let formatter = ValueFormatter(style: .medium)
    private let validatorImageFormatter = AssetImageFormatter()
    
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
    
    private var asset: Asset {
        delegation.base.assetId.chain.asset
    }
    
    var state: DelegationState {
        delegation.base.state
    }
    
    var stateText: String {
        delegation.base.state.title
    }
    
    var stateTextColor: Color {
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
    
    
    var balanceText: String {
        formatter.string(delegation.base.balanceValue, decimals: asset.decimals.asInt, currency: asset.symbol)
    }
    
    var rewardsText: String? {
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
    
    var balanceTextStyle: TextStyle {
        TextStyle(font: Font.system(.body), color: .primary)
    }
    
    var validatorText: String {
        if delegation.validator.name.isEmpty {
            return AddressFormatter(style: .short, address: delegation.validator.id, chain: asset.chain).value()
        }
        return delegation.validator.name
    }
    
    var validatorImageUrl: URL? {
        validatorImageFormatter.getValidatorUrl(chain: asset.chain, id: delegation.validator.id)
    }
    
    var completionDateText: String? {
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
    var id: String { delegation.id }
}
