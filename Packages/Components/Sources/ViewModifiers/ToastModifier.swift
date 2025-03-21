// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

struct ToastModifier: ViewModifier {
    @State var isPresenting: Binding<Bool>
    let value: String
    let systemImage: String

    init(
        isPresenting: Binding<Bool>,
        value: String,
        systemImage: String
    ) {
        self.isPresenting = isPresenting
        self.value = value
        self.systemImage = systemImage
    }

    func body(content: Content) -> some View {
        return content
            .toast(isPresenting: isPresenting){
                AlertToast(
                    displayMode: .banner(.pop),
                    type: .systemImage(systemImage, Colors.black),
                    title: value
                )
            }
    }
}

// MARK: - View Modifier

public extension View {
    func toast(isPresenting: Binding<Bool>, title: String, systemImage: String) -> some View {
        self.modifier(
            ToastModifier(
                isPresenting: isPresenting,
                value: title,
                systemImage: systemImage)
        )
    }
}
