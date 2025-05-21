// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components
import Localization

// TODO: - migrate to Observable macro, main actor
public class StakeValidatorsViewModel: ObservableObject {
    
    private let type: StakeValidatorsType
    private let chain: Chain
    public let currentValidator: DelegationValidator?
    private let validators: [DelegationValidator]
    public var selectValidator: ((DelegationValidator) -> Void)?
    
    private let recommendedValidators = StakeRecommendedValidators()
    
    public init(
        type: StakeValidatorsType,
        chain: Chain,
        currentValidator: DelegationValidator?,
        validators: [DelegationValidator],
        selectValidator: ((DelegationValidator) -> Void)? = nil
    ) {
        self.type = type
        self.chain = chain
        self.currentValidator = currentValidator
        self.validators = validators
        self.selectValidator = selectValidator
    }
    
    public var title: String {
        return Localized.Stake.validators
    }
    
    public var list: [ListItemValueSection<DelegationValidator>] {
        switch type {
        case .stake:
            let recommeneded = recommendedValidators.validatorsSet(chain: chain)
            return [
                listSection(
                    title: Localized.Common.recommended,
                    validators: validators.filter { recommeneded.contains($0.id) }
                ),
                listSection(
                    title: Localized.Stake.active,
                    validators: validators
                ),
            ].filter { $0.values.count > 0 }
        case .unstake:
            return [
                listSection(
                    title: Localized.Stake.active,
                    validators: validators
                )
            ]
        }
    }
    
    public func listSection(title: String, validators: [DelegationValidator]) -> ListItemValueSection<DelegationValidator> {
        ListItemValueSection(
            section: title,
            values: validators.map(listItem)
        )
    }
    
    public func listItem(validator: DelegationValidator) -> ListItemValue<DelegationValidator> {
        let model = StakeValidatorViewModel(validator: validator)
        return ListItemValue(
            title: model.name,
            subtitle: model.aprText,
            value: validator
        )
    }
}
