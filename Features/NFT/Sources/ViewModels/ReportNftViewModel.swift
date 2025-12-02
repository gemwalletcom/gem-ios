// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import NFTService
import Style
import Localization
import Components

@Observable
@MainActor
public final class ReportNftViewModel {
    private let nftService: NFTService
    private let assetData: NFTAssetData
    private let onComplete: VoidAction

    var state: StateViewType<Bool> = .noData
    var reason: String = ""

    let reasons = ReportReasonViewModel.allCases

    public init(
        nftService: NFTService,
        assetData: NFTAssetData,
        onComplete: VoidAction
    ) {
        self.nftService = nftService
        self.assetData = assetData
        self.onComplete = onComplete
    }

    var title: String { Localized.Nft.Report.title }
    var progressMessage: String { Localized.Common.loading }

    var submitButtonState: ButtonState {
        if state.isLoading {
            return .loading()
        }
        return reason.isEmpty ? .disabled : .normal
    }

    func submitUserReport() {
        submitReport(reason: reason)
    }

    func submitReport(reason: String) {
        state = .loading
        Task {
            do {
                try await nftService.report(
                    collectionId: assetData.collection.id,
                    assetId: assetData.asset.id,
                    reason: reason
                )
                state = .data(true)
                onComplete?()
            } catch {
                debugLog("Report NFT error: \(error)")
                state = .error(error)
            }
        }
    }
}
