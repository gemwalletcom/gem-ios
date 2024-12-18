// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Intro

struct IntroNavigationView: View {

    @State private var isPresentingCreateWalletSheet = false
    @State private var isPresentingImportWalletSheet = false

    var body: some View {
        IntroScene(
            model: IntroViewModel(),
            isPresentingCreateWalletSheet: $isPresentingCreateWalletSheet,
            isPresentingImportWalletSheet: $isPresentingImportWalletSheet
        )
        .sheet(isPresented: $isPresentingCreateWalletSheet) {
            CreateWalletNavigationStack()
        }
        .sheet(isPresented: $isPresentingImportWalletSheet) {
            ImportWalletNavigationStack()
        }
    }
}
