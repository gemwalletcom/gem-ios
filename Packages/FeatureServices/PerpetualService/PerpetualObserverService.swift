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

        updateTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self, let wallet = await self.currentWallet else { return }
                do {
                    let positions = try await self.perpetualService.getPositions(walletId: wallet.walletId)

                    if let address = wallet.perpetualAddress, positions.isNotEmpty {
                        try await self.perpetualService.updatePositions(address: address, walletId: wallet.walletId)
                    }
                } catch {
                    debugLog("PerpetualObserverService error getting positions: \(error)")
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
