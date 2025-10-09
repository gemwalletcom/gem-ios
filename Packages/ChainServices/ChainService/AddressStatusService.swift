// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Blockchain

public struct AddressStatusService: Sendable {
    
    private let chainServiceFactory: ChainServiceFactory
    private let chains: [Chain] = [.tron]

    public init(
        chainServiceFactory: ChainServiceFactory
    ) {
        self.chainServiceFactory = chainServiceFactory 
    }
    
    public func getAddressStatus(accounts: [Account]) async throws -> [Account: [AddressStatus]] {
        var result: [Account: [AddressStatus]] = [:]
        let accounts = accounts.filter { chains.contains($0.chain) }
        
        for account in accounts {
            let status = try await chainServiceFactory.service(for: account.chain).getAddressStatus(
                address: account.address
            )
            result[account] = status
        }
        return result
    }
}
