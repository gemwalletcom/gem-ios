// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Localization
import Primitives
import Onboarding

struct WalletsNavigationStack: View {
    @Environment(\.walletService) private var walletService
    @Environment(\.keystore) private var keystore

    @State private var navigationPath = NavigationPath()

    @State private var isPresentingCreateWalletSheet = false
    @State private var isPresentingImportWalletSheet = false
    @Binding private var isPresentingWallets: Bool

    init(isPresentingWallets: Binding<Bool>) {
        _isPresentingWallets = isPresentingWallets
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            WalletsScene(
                model: WalletsViewModel(navigationPath: $navigationPath, walletService: walletService),
                isPresentingCreateWalletSheet: $isPresentingCreateWalletSheet,
                isPresentingImportWalletSheet: $isPresentingImportWalletSheet
            )
            .navigationDestination(for: Scenes.WalletDetail.self) {
                WalletDetailScene(
                    model: WalletDetailViewModel(
                        navigationPath: $navigationPath,
                        wallet: $0.wallet,
                        keystore: keystore
                    )
                )
            }
            .navigationDestination(for: Scenes.WalletSelectImage.self) {
                WalletSelectImageScene(
                    model: WalletSelectImageViewModel(
                        navigationPath: $navigationPath,
                        wallet: $0.wallet
                    )
                )
            }
            .sheet(isPresented: $isPresentingCreateWalletSheet) {
                CreateWalletNavigationStack(
                    keystore: keystore,
                    isPresentingWallets: $isPresentingWallets
                )
            }
            .sheet(isPresented: $isPresentingImportWalletSheet) {
                ImportWalletNavigationStack(
                    model: ImportWalletTypeViewModel(keystore: keystore),
                    isPresentingWallets: $isPresentingWallets
                )
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(Localized.Common.done) {
                        isPresentingWallets.toggle()
                    }
                    .bold()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
