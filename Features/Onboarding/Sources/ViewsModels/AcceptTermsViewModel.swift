// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import GemstonePrimitives
import Primitives

@Observable
final class AcceptTermsViewModel {
    let onNext: VoidAction
    
    init(onNext: VoidAction) {
        self.onNext = onNext
    }
    
    var termsAndServicesURL: URL {
        PublicConstants.url(.termsOfService)
    }
    
    let title: String = "Accept Terms"
    let message: String = "Please read and agree to the following terms before you continue."

    var items: [AcceptTermViewModel] = [
        .init(message: "I understand that I am solely responsible for the security and backup of my wallets, not Gem."),
        .init(message: "I understand that Gem is not a bank or exchange, and using it for illegal purposes is strictly prohibited."),
        .init(message: "I understand that if I ever lose access to my wallets, Gem is not liable and cannot help in any way.")
    ]
    
    var isConfirmed: Bool {
        items.allSatisfy { $0.isConfirmed }
    }
    
    var buttonState: StateViewType<Bool> {
        isConfirmed ? .data(true) : .noData
    }
}
