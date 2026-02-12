// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import ChainService
import Primitives
import Blockchain
import BlockchainTestKit

public final class ChainServiceFactoryMock: ChainServiceFactorable, Sendable {

    private let chainService: any ChainServiceable

    public var requestInterceptor: any RequestInterceptable {
        EmptyRequestInterceptor()
    }

    public init(chainService: any ChainServiceable = ChainServiceMock()) {
        self.chainService = chainService
    }

    public func service(for chain: Chain) -> any ChainServiceable {
        chainService
    }
}
