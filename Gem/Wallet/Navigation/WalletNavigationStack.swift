// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives

struct WalletNavigationStack: View {
    
    @State private var isWalletsPresented = false
    @State private var isPresentingCreateWalletSheet = false
    @State private var isPresentingImportWalletSheet = false
    
    @Environment(\.walletService) private var walletService

    let model: WalletSceneViewModel
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            WalletScene(model: model)
            .sheet(isPresented: $isWalletsPresented) {
                WalletsNavigationStack()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .environment(\.isWalletsPresented, $isWalletsPresented)
    }
}

//#Preview {
//    WalletNavigationStack()
//}
