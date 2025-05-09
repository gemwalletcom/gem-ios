// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

struct ToastModifier: ViewModifier {
    private var isPresenting: Binding<Bool>

    private let value: String
    private let systemImage: String

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
        content
            .toast(isPresenting: isPresenting) {
                AlertToast(
                    displayMode: .banner(.pop),
                    type: .systemImage(systemImage, Colors.black),
                    title: value
                )
            }
    }
}

private struct OptionalMessageToastModifier: ViewModifier {
    @Binding var message: String?
    let systemImage: String

    func body(content: Content) -> some View {
        content.modifier(
            ToastModifier(
                isPresenting: Binding(
                    get: { message != nil },
                    set: { showing in
                        if showing == false { message = nil }
                    }
                ),
                value: message ?? "",
                systemImage: systemImage
            )
        )
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

    func toast(message: Binding<String?>, systemImage: String) -> some View {
        self.modifier(
            OptionalMessageToastModifier(
                message: message,
                systemImage: systemImage
            )
        )
    }
}
