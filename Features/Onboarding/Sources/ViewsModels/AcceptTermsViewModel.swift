// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import GemstonePrimitives
import Primitives
import Localization

@Observable
final class AcceptTermsViewModel {
    let onNext: VoidAction
    
    init(onNext: VoidAction) {
        self.onNext = onNext
    }
    
    var termsAndServicesURL: URL {
        PublicConstants.url(.termsOfService)
    }
    
    let title: String = Localized.Onboarding.AcceptTerms.title
    let message: String = Localized.Onboarding.AcceptTerms.message

    var items: [TermItemViewModel] = [
        .init(message: Localized.Onboarding.AcceptTerms.Item1.message),
        .init(message: Localized.Onboarding.AcceptTerms.Item2.message),
        .init(message: Localized.Onboarding.AcceptTerms.Item3.message)
    ]
    
    var isConfirmed: Bool {
        items.allSatisfy { $0.isConfirmed }
    }
    
    var state: StateViewType<Bool> {
        isConfirmed ? .data(true) : .noData
    }
}
