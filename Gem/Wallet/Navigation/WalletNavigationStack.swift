// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives

struct WalletNavigationStack: View {
    
    @State private var isWalletsPresented = false
    @State private var isPresentingCreateWalletSheet = false
    @State private var isPresentingImportWalletSheet = false
    
    @Environment(\.keystore) private var keystore
    
    let wallet: Wallet
    let walletModel: WalletSceneViewModel
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            WalletScene(
                wallet: wallet,
                model: walletModel
            )
            .sheet(isPresented: $isWalletsPresented) {
                NavigationStack {
                    WalletsScene(model: WalletsViewModel(keystore: keystore))
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(Localized.Common.done) {
                                    isWalletsPresented.toggle()
                                }
                                .bold()
                            }
                        }
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .environment(\.isWalletsPresented, $isWalletsPresented)
    }
}

//#Preview {
//    WalletNavigationStack()
//}
