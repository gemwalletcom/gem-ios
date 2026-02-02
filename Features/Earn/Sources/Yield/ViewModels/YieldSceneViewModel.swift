// Copyright (c). Gem Wallet. All rights reserved.

import Components
import Foundation
import struct Gemstone.GemYieldPosition
import enum Gemstone.GemYieldProvider
import GemstonePrimitives
import Localization
import Primitives
import Style
import YieldService

@MainActor
@Observable
public final class YieldSceneViewModel {
    public let wallet: Wallet
    public let asset: Asset
    private let yieldService: any YieldServiceType
    private let onAmountInputAction: AmountInputAction

    public private(set) var state: YieldState = .idle

    public var title: String {
        Localized.Common.earn
    }

    public var assetName: String {
        asset.name
    }

    public var assetSymbol: String {
        asset.symbol
    }

    public var assetImage: AssetImage {
        AssetImage(
            type: asset.type.rawValue,
            imageURL: AssetImageFormatter.shared.getURL(for: asset.id),
            placeholder: nil,
            chainPlaceholder: Images.YieldProviders.yo
        )
    }

    public var isLoading: Bool {
        state.isLoading
    }

    public var protocols: [YieldProtocolViewModel] {
        state.protocols
    }

    public var position: YieldPositionViewModel? {
        state.position
    }

    public var hasPosition: Bool {
        position?.hasBalance ?? false
    }

    public var hasProtocols: Bool {
        !protocols.isEmpty
    }

    public var hasError: Bool {
        state.hasError
    }

    public var errorMessage: String? {
        state.error?.localizedDescription
    }

    public var emptyStateTitle: String {
        "No yield protocols available"
    }

    public var walletAddress: String {
        (try? wallet.account(for: asset.id.chain))?.address ?? ""
    }

    public init(
        wallet: Wallet,
        asset: Asset,
        yieldService: any YieldServiceType,
        onAmountInputAction: AmountInputAction = nil
    ) {
        self.wallet = wallet
        self.asset = asset
        self.yieldService = yieldService
        self.onAmountInputAction = onAmountInputAction
    }

    public func fetchOnce() {
        Task {
            await fetch()
        }
    }

    public func fetch() async {
        state = .loading

        do {
            let yields = try await yieldService.getYields(for: asset.id)
            let protocols = yields.map { YieldProtocolViewModel(yield: $0) }

            let cached = yieldService.getPosition(
                provider: .yo,
                asset: asset.id,
                walletAddress: walletAddress,
                walletId: wallet.walletId
            ) { [weak self] fresh in
                self?.updatePosition(fresh, protocols: protocols)
            }

            let positionViewModel = cached.map {
                YieldPositionViewModel(position: $0, decimals: Int(asset.decimals))
            }
            state = .loaded(protocols, positionViewModel)
        } catch {
            state = .error(error)
        }
    }

    private func updatePosition(_ position: GemYieldPosition, protocols: [YieldProtocolViewModel]) {
        let positionViewModel = YieldPositionViewModel(
            position: position,
            decimals: Int(asset.decimals)
        )
        state = .loaded(protocols, positionViewModel)
    }

    public func onSelectProtocol(_ opportunity: YieldProtocolViewModel) {
        let earnData = EarnData(
            provider: opportunity.provider.name,
            contractAddress: nil,
            callData: nil,
            approval: nil,
            gasLimit: nil
        )
        let amountInput = AmountInput(
            type: .yield(action: .deposit, data: earnData, depositedBalance: nil),
            asset: asset
        )
        onAmountInputAction?(amountInput)
    }

    public func onWithdraw() {
        guard let position = position else { return }
        let earnData = EarnData(
            provider: position.providerName,
            contractAddress: nil,
            callData: nil,
            approval: nil,
            gasLimit: nil
        )
        let amountInput = AmountInput(
            type: .yield(action: .withdraw, data: earnData, depositedBalance: position.vaultBalance),
            asset: asset
        )
        onAmountInputAction?(amountInput)
    }
}
