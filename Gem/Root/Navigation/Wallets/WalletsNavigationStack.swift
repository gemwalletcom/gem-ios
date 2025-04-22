// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Localization
import Primitives
import Onboarding
import ManageWallets
import WalletAvatar

struct WalletsNavigationStack: View {
    @Environment(\.walletService) private var walletService
    @Environment(\.avatarService) private var avatarService

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
                model: WalletsSceneViewModel(
                    navigationPath: $navigationPath,
                    walletService: walletService
                ),
                isPresentingCreateWalletSheet: $isPresentingCreateWalletSheet,
                isPresentingImportWalletSheet: $isPresentingImportWalletSheet
            )
            .navigationDestination(for: Scenes.WalletDetail.self) {
                WalletDetailScene(
                    model: WalletDetailViewModel(
                        navigationPath: $navigationPath,
                        wallet: $0.wallet,
                        walletService: walletService
                    )
                )
            }
            .navigationDestination(for: Scenes.WalletSelectImage.self) {
                WalletImageScene(model: WalletImageViewModel(
                    wallet: $0.wallet,
                    avatarService: avatarService
                ))
            }
            .sheet(isPresented: $isPresentingCreateWalletSheet) {
                CreateWalletNavigationStack(
                    walletService: walletService,
                    isPresentingWallets: $isPresentingWallets
                )
            }
            .sheet(isPresented: $isPresentingImportWalletSheet) {
                ImportWalletNavigationStack(
                    model: ImportWalletTypeViewModel(walletService: walletService),
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
