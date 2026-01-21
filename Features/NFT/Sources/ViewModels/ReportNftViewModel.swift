// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import NFTService
import Localization
import Components

@Observable
@MainActor
public final class ReportNftViewModel {
    private let nftService: NFTService
    private let assetData: NFTAssetData
    private let onComplete: VoidAction

    var state: StateViewType<Bool> = .noData

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

    var title: String { Localized.Nft.Report.reportButtonTitle }
    var progressMessage: String { Localized.Common.loading }

    func submitReport(reason: String) {
        state = .loading
        Task { [weak self] in
            guard let self else { return }
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
