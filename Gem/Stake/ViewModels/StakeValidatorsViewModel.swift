// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components

enum StakeValidatorsType {
    case stake
    case unstake
}

class StakeValidatorsViewModel: ObservableObject {
    
    let type: StakeValidatorsType
    let chain: Chain
    let currentValidator: DelegationValidator?
    let validators: [DelegationValidator]
    var selectValidator: ((DelegationValidator) -> Void)?
    
    private let recommendedValidators = StakeRecommendedValidators()
    
    init(
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
    
    var title: String {
        return Localized.Stake.validators
    }
    
    var list: [ListItemValueSection<DelegationValidator>] {
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
    
    func listSection(title: String, validators: [DelegationValidator]) -> ListItemValueSection<DelegationValidator> {
        ListItemValueSection(
            section: title,
            values: validators.map(listItem)
        )
    }
    
    func listItem(validator: DelegationValidator) -> ListItemValue<DelegationValidator> {
        let model = StakeValidatorViewModel(validator: validator)
        return ListItemValue(
            title: model.name,
            subtitle: model.aprText,
            value: validator
        )
    }
}
