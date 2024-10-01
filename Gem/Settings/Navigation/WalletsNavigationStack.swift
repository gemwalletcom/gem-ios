// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI

struct WalletsNavigationStack: View {

    @Environment(\.isWalletsPresented) private var isWalletsPresented
    @Environment(\.walletService) private var walletService
    @Environment(\.keystore) private var keystore

    @State var navigationPath = NavigationPath()

    @State private var isPresentingCreateWalletSheet = false
    @State private var isPresentingImportWalletSheet = false

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
                CreateWalletNavigationStack(isPresenting: $isPresentingCreateWalletSheet)
            }
            .sheet(isPresented: $isPresentingImportWalletSheet) {
                ImportWalletNavigationStack(isPresenting: $isPresentingImportWalletSheet)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(Localized.Common.done) {
                        isWalletsPresented.wrappedValue.toggle()
                    }
                    .bold()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }

    }
}
