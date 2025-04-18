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
                manageWalletService: model.manageWalletService,
                isPresentingWallets: .constant(false)
            )
        }
        .sheet(isPresented: $isPresentingImportWalletSheet) {
            ImportWalletNavigationStack(
                model: ImportWalletTypeViewModel(manageWalletService: model.manageWalletService),
                isPresentingWallets: .constant(false)
            )
        }
    }
}
