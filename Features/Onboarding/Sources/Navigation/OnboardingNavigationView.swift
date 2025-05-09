// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI

public struct OnboardingNavigationView: View {
    @State private var isPresentingCreateWalletSheet = false
    @State private var isPresentingImportWalletSheet = false

    private let model: OnboardingViewModel

    public init(model: OnboardingViewModel) {
        self.model = model
    }

    public var body: some View {
        OnboardingScene(
            model: model,
            isPresentingCreateWalletSheet: $isPresentingCreateWalletSheet,
            isPresentingImportWalletSheet: $isPresentingImportWalletSheet
        )
        .sheet(isPresented: $isPresentingCreateWalletSheet) {
            CreateWalletNavigationStack(
                walletService: model.walletService,
                onFinishFlow: nil
            )
        }
        .sheet(isPresented: $isPresentingImportWalletSheet) {
            ImportWalletNavigationStack(walletService: model.walletService)
        }
    }
}
