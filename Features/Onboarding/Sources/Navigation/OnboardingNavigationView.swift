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
                    model: CreateWalletModel(
                        walletService: model.walletService,
                        avatarService: model.avatarService,
                        isPresentingWallets: $model.isPresentingCreateWalletSheet
                    )
                )
            }
            .sheet(isPresented: $model.isPresentingImportWalletSheet) {
                ImportWalletNavigationStack(
                    model: ImportWalletViewModel(
                        walletService: model.walletService,
                        avatarService: model.avatarService,
                        nameService: model.nameService,
                        isPresentingWallets: $model.isPresentingImportWalletSheet
                    )
                )
            }
    }
}
