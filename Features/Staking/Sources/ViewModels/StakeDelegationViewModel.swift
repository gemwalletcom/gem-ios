// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components
import SwiftUI
import Style
import Preferences
import ExplorerService
import GemstonePrimitives
import Formatters
import PrimitivesComponents
import Localization

public struct StakeDelegationViewModel: Sendable {
    
    public let delegation: Delegation
    private let formatter: ValueFormatter
    private let validatorImageFormatter = AssetImageFormatter()
    private let exploreService: ExplorerService = .standard
    private let priceFormatter = CurrencyFormatter(type: .currency, currencyCode: Preferences.standard.currency)

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
    
    public init(delegation: Delegation, formatter: ValueFormatter = ValueFormatter(style: .short)) {
        self.delegation = delegation
        self.formatter = formatter
    }
    
    private var asset: Asset {
        delegation.base.assetId.chain.asset
    }
    
    public var state: DelegationState {
        delegation.base.state
    }
    
    public var navigationDestination: any Hashable {
        switch state {
        case .active, .pending, .undelegating, .inactive, .activating, .deactivating:
            delegation
        case .awaitingWithdrawal:
            TransferData(
                type: .stake(asset, .withdraw(delegation)),
                recipientData: RecipientData(
                    recipient: Recipient(name: validatorText, address: delegation.validator.id, memo: ""),
                    amount: .none
                ),
                value: delegation.base.balanceValue
            )
        }
    }
    
    public var stateText: String? {
        switch state {
        case .active: nil
        case .pending, .undelegating, .inactive, .activating, .deactivating, .awaitingWithdrawal: delegation.base.state.title
        }
    }
    
    public var titleStyle: TextStyle {
        TextStyle(font: .body, color: .primary, fontWeight: .semibold)
    }
    
    public var stateTagStyle: TextStyle {
        TextStyle(
            font: .footnote,
            color: stateTextColor,
            background: stateTextColor.opacity(0.15)
        )
    }
    
    public var titleExtraStyle: TextStyle {
        TextStyle(font: .footnote, color: Colors.gray)
    }
    
    public var subtitleStyle: TextStyle {
        TextStyle(font: .callout, color: Colors.black, fontWeight: .semibold)
    }
    
    public var subtitleExtraStyle: TextStyle {
        TextStyle(font: .footnote, color: Colors.gray)
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
    
    public var fiatValueText: String? {
        guard
            let price = delegation.price,
            let balance = try? formatter.double(from: delegation.base.balanceValue, decimals: asset.decimals.asInt)
        else { return nil }
        return priceFormatter.string(price.price * balance)
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
    
    public var rewardsFiatValueText: String? {
        guard
            let price = delegation.price,
            delegation.base.rewardsValue > 0,
            let rewards = try? formatter.double(from: delegation.base.rewardsValue, decimals: asset.decimals.asInt)
        else { return nil }
        return priceFormatter.string(price.price * rewards)
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
    
    public var validatorImage: AssetImage {
        AssetImage(
            type: String(validatorText.first ?? " "),
            imageURL: validatorImageFormatter.getValidatorUrl(chain: asset.chain, id: delegation.validator.id)
        )
    }
    
    public var validatorUrl: URL? {
        guard delegation.validator.id != DelegationValidator.systemId else { return nil }
        return exploreService.validatorUrl(chain: asset.chain, address: delegation.validator.id)?.url
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
