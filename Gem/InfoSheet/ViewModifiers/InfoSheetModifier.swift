// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

struct InfoSheetModifier: ViewModifier {
    @Binding var isPresented: Bool

    let viewModel: InfoSheetViewModel

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                InfoSheet(viewModel: viewModel)
            }
    }
}

// Usage of the modifier
extension View {
    func infoSheet(isPresented: Binding<Bool>, viewModel: InfoSheetViewModel) -> some View {
        self.modifier(InfoSheetModifier(isPresented: isPresented, viewModel: viewModel))
    }
}
