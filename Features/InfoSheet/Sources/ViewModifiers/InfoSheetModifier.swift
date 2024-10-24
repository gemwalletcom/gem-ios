// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components

public struct InfoSheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    let model: any InfoSheetModelViewable

    init(
        isPresented: Binding<Bool>,
        model: any InfoSheetModelViewable
    ) {
        _isPresented = isPresented
        self.model = model
    }
    
    public func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                InfoSheetScene(model: model)
            }
    }
}

// MARK: - Modifier

extension View {
    public func infoSheet(isPresented: Binding<Bool>, model: any InfoSheetModelViewable) -> some View {
        self.modifier(InfoSheetModifier(isPresented: isPresented, model: model))
    }
}
