// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Combine
import Web3Wallet
//import Auth

final class WCConnectionsInteractor {

    var sessionsPublisher: AnyPublisher<[Session], Never> {
        return Web3Wallet.instance.sessionsPublisher
    }
    
    var sessionProposalPublisher: AnyPublisher<(proposal: Session.Proposal, context: VerifyContext?), Never> {
        return Web3Wallet.instance.sessionProposalPublisher
    }
    
    var sessionRequestPublisher: AnyPublisher<(request: Request, context: VerifyContext?), Never> {
        return Web3Wallet.instance.sessionRequestPublisher
    }
    
//    var authRequestPublisher: AnyPublisher<(request: AuthRequest, context: VerifyContext?), Never> {
//        return Web3Wallet.instance.authRequestPublisher
//    }
}
