// Copyright (c). Gem Wallet. All rights reserved.

import Web3Wallet

final class WCConnectionsInteractor {
    var sessionsStream: AsyncStream<[Session]> {
        Web3Wallet.instance.sessionsPublisher.asAsyncStream()
    }

    var sessionProposalStream: AsyncStream<(proposal: Session.Proposal, context: VerifyContext?)> {
        Web3Wallet.instance.sessionProposalPublisher.asAsyncStream()
    }

    var sessionRequestStream: AsyncStream<(request: Request, context: VerifyContext?)> {
        Web3Wallet.instance.sessionRequestPublisher.asAsyncStream()
    }
}
