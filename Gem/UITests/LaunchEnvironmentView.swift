// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import WalletServiceTestKit
import PreferencesTestKit
import WalletService
import KeystoreTestKit
import Keystore
import AssetsServiceTestKit
import WalletsServiceTestKit
import PriceAlertServiceTestKit
import Primitives
import Store
import WalletTabTestKit

// Features
import Onboarding
import WalletTab

public struct LaunchEnvironmentView: View {
    let launchEnvironment: UITestLaunchScenario
    
    public init(launchEnvironment: UITestLaunchScenario) {
        self.launchEnvironment = launchEnvironment
    }
    
    public var body: some View {
        switch launchEnvironment {
            case .onboarding:
            OnboardingScene(
                model: OnboardingViewModel(walletService: .mock()),
                isPresentingCreateWalletSheet: .constant(false),
                isPresentingImportWalletSheet: .constant(false)
            )
        case .createFirstWallet:
            CreateWalletNavigationStack(
                walletService: .mock(isAcceptedTerms: false),
                isPresentingWallets: .constant(false)
            )
        case .createWallet:
            CreateWalletNavigationStack(
                walletService: .mock(isAcceptedTerms: true),
                isPresentingWallets: .constant(false)
            )
        case .importWallet:
            ImportWalletNavigationStack(
                model: ImportWalletTypeViewModel(walletService: .mock(isAcceptedTerms: true)),
                isPresentingWallets: .constant(false)
            )
        
        case .exportWords:
            ExportWalletNavigationStack(
                flow: .words(LocalKeystore.words)
            )
        case .exportPrivateKey:
            ExportWalletNavigationStack(
                flow: .privateKey(LocalKeystore.privateKey)
            )
        case .selectAssetManage:
            let db = DB.mockAssets()
            SelectAssetSceneNavigationStack(
                model: SelectAssetViewModel.mock(db: db, selectType: .manage),
                isPresentingSelectType: .constant(nil)
            )
            .databaseContext(.readWrite { db.dbQueue })
        case .walletsList:
            WalletsNavigationStack(
                isPresentingWallets: .constant(false)
            )
        case .assetScene:
            WalletNavigationStack(
                model: .mock()
            )
            .databaseContext(.readWrite { DB.mockAssets().dbQueue })
        }
    }
}
