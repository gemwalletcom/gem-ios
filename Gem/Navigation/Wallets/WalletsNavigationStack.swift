// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Localization
import Primitives
import Onboarding
import ManageWallets
import WalletAvatar
import WalletService

struct WalletsNavigationStack: View {
    @Environment(\.avatarService) private var avatarService
    @Environment(\.walletService) private var walletService

    @State private var navigationPath = NavigationPath()
    @State private var model: WalletsSceneViewModel?
    @Binding private var isPresentingWallets: Bool

    init(isPresentingWallets: Binding<Bool>) {
        _isPresentingWallets = isPresentingWallets
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if let model = model {
                    WalletsScene(
                        model: model
                    )
                    .sheet(isPresented: Binding(
                        get: { model.isPresentingCreateWalletSheet },
                        set: { model.isPresentingCreateWalletSheet = $0 }
                    )) {
                        CreateWalletNavigationStack(
                            walletService: model.service,
                            isPresentingWallets: $isPresentingWallets
                        )
                    }
                    .sheet(isPresented: Binding(
                        get: { model.isPresentingImportWalletSheet },
                        set: { model.isPresentingImportWalletSheet = $0 }
                    )) {
                        ImportWalletNavigationStack(
                            model: ImportWalletTypeViewModel(walletService: model.service),
                            isPresentingWallets: $isPresentingWallets
                        )
                    }
                    .onChange(of: model.walletToEdit) { _, wallet in
                        if let wallet = wallet {
                            navigationPath.append(Scenes.WalletDetail(wallet: wallet))
                            model.walletToEdit = nil
                        }
                    }
                } else {
                    ProgressView()
                }
            }
        }
        .navigationDestination(for: Scenes.WalletDetail.self) {
                WalletDetailScene(
                    model: WalletDetailViewModel(
                        navigationPath: $navigationPath,
                        wallet: $0.wallet,
                        walletService: model?.service ?? walletService
                    )
                )
            }
            .navigationDestination(for: Scenes.WalletSelectImage.self) {
                WalletImageScene(model: WalletImageViewModel(
                    wallet: $0.wallet,
                    avatarService: avatarService
                ))
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
            .onAppear {
                if model == nil {
                    model = WalletsSceneViewModel(walletService: walletService)
                }
            }
    }
}
