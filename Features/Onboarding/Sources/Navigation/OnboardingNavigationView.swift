// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI

public struct OnboardingNavigationView: View {
    @State private var model: OnboardingViewModel

    public init(model: OnboardingViewModel) {
        _model = State(wrappedValue: model)
    }

    public var body: some View {
        OnboardingScene(model: model)
            .sheet(isPresented: $model.isPresentingCreateWalletSheet) {
                CreateWalletNavigationStack(
                    walletService: model.walletService,
                    isPresentingWallets: .constant(false)
                )
            }
            .sheet(isPresented: $model.isPresentingImportWalletSheet) {
                ImportWalletNavigationStack(
                    model: ImportWalletTypeViewModel(walletService: model.walletService),
                    isPresentingWallets: .constant(false)
                )
            }
    }
}
