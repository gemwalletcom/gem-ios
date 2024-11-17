// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Localization
import GemstonePrimitives
import Primitives
import Style

public struct InfoSheetViewModel {
    private let type: InfoSheetType

    public init(type: InfoSheetType) {
        self.type = type
    }
}

// MARK: - InfoSheetModelViewable

extension InfoSheetViewModel: InfoSheetModelViewable {
    public var url: URL? {
        switch type {
        case .networkFee: Docs.url(.networkFees)
        case .transactionState: Docs.url(.transactionStatus)
        case .watchWallet: Docs.url(.whatIsWatchWallet)
        }
    }

    public var title: String {
        switch type {
        case .networkFee: Localized.Info.NetworkFee.title
        case .transactionState(_, let state):
            switch state {
            case .pending: Localized.Transaction.Status.pending
            case .confirmed: Localized.Transaction.Status.confirmed
            case .failed: Localized.Transaction.Status.failed
            case .reverted: Localized.Transaction.Status.reverted
            }
        case .watchWallet: Localized.Info.WatchWallet.title
        }
    }

    public var description: String {
        switch type {
        case .networkFee(let chain): Localized.Info.NetworkFee.description(chain.asset.name)
        case .transactionState(_, let state):
            switch state {
            case .pending: Localized.Info.Transaction.Pending.description
            case .confirmed: Localized.Info.Transaction.Success.description
            case .failed, .reverted: Localized.Info.Transaction.Error.description
            }
        case .watchWallet: Localized.Info.WatchWallet.description
        }
    }

    public var image: InfoSheetImage? {
        switch type {
        case .networkFee: return .image(Images.Info.networkFee)
        case .transactionState(let imageURL, let state):
            let stateImage = switch state {
            case .pending: Images.Transaction.State.pending
            case .confirmed: Images.Transaction.State.success
            case .failed, .reverted: Images.Transaction.State.error
            }
            return .assetImage(
                AssetImage(
                    imageURL: imageURL,
                    placeholder: .none,
                    chainPlaceholder: stateImage
                )
            )
        case .watchWallet:
            return .assetImage(
                AssetImage(
                    imageURL: .none,
                    placeholder: Images.Logo.logo,
                    chainPlaceholder: Images.Wallets.watch
                )
            )
        }
    }
    
    public var buttonTitle: String { Localized.Common.learnMore }
}
