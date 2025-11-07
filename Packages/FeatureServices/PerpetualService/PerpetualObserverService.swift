// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public actor PerpetualObserverService: Sendable {
    
    private let perpetualService: PerpetualServiceable
    private var updateTask: Task<Void, Never>?
    private var currentWallet: Wallet?
    
    public init(perpetualService: PerpetualServiceable) {
        self.perpetualService = perpetualService
    }
    
    deinit {
        updateTask?.cancel()
    }
    
    public func connect(for wallet: Wallet) async {
        guard currentWallet?.id != wallet.id else { return }
        
        await disconnect()
        currentWallet = wallet
        
        updateTask = Task {
            while !Task.isCancelled {
                do {
                    let positions = try await perpetualService.getPositions(walletId: wallet.walletId)
                    
                    if positions.isNotEmpty {
                        try await perpetualService.updatePositions(wallet: wallet)
                    }
                } catch {
                    #debugLog("PerpetualObserverService error getting positions: \(error)")
                }
                
                try? await Task.sleep(for: .seconds(5))
            }
        }
    }
    
    public func disconnect() async {
        updateTask?.cancel()
        updateTask = nil
        currentWallet = nil
    }
}
