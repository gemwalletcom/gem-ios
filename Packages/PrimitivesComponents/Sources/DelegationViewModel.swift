// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components
import SwiftUI
import Style
import Formatters
import Localization

public struct DelegationViewModel: Sendable {

    public let delegation: Delegation
    public let currencyCode: String
    private let asset: Asset
    private let formatter: ValueFormatter
    private let validatorImageFormatter = AssetImageFormatter()
    private let priceFormatter: CurrencyFormatter

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

    public init(
        delegation: Delegation,
        asset: Asset? = nil,
        formatter: ValueFormatter = .short,
        currencyCode: String
    ) {
        self.delegation = delegation
        self.currencyCode = currencyCode
        self.asset = asset ?? delegation.base.assetId.chain.asset
        self.formatter = formatter
        self.priceFormatter = CurrencyFormatter(type: .currency, currencyCode: currencyCode)
    }

    public var state: DelegationState {
        delegation.base.state
    }

    public var stateText: String? {
        DelegationStateViewModel(state: state).title
    }

    public var titleStyle: TextStyle {
        TextStyle(font: .body, color: .primary, fontWeight: .semibold)
    }

    public var stateStyle: TextStyle {
        TextStyle(font: .footnote, color: stateTextColor)
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
            if delegation.base.rewardsValue == 0 {
                return .none
            }
            return formatter.string(delegation.base.rewardsValue, decimals: asset.decimals.asInt, currency: asset.symbol)
        case .pending,
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

    public var validatorText: String {
        switch delegation.validator.providerType {
        case .earn:
            guard let provider = YieldProvider(rawValue: delegation.validator.id) else { return delegation.validator.name }
            return YieldProviderViewModel(provider: provider).displayName
        case .stake:
            if delegation.validator.name.isEmpty {
                return AddressFormatter(style: .short, address: delegation.validator.id, chain: asset.chain).value()
            }
            return delegation.validator.name
        }
    }

    public var validatorImage: AssetImage {
        switch delegation.validator.providerType {
        case .stake:
            return AssetImage(
                type: String(validatorText.first ?? " "),
                imageURL: validatorImageFormatter.getValidatorUrl(chain: asset.chain, id: delegation.validator.id)
            )
        case .earn:
            return AssetImage(placeholder: YieldProvider(rawValue: delegation.validator.id).map { YieldProviderViewModel(provider: $0).image })
        }
    }

    public var completionDateText: String? {
        let now = Date.now
        if let completionDate = delegation.base.completionDate, completionDate > now {
            if now.distance(to: completionDate) < 86400 {
                return Self.dateFormatterDay.string(from: .now, to: completionDate)
            }
            return Self.dateFormatterDefault.string(from: .now, to: completionDate)
        }
        return .none
    }
}

extension DelegationViewModel: Identifiable {
    public var id: String { delegation.id }
}
