// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

struct ToastModifier: ViewModifier {
    private var isPresenting: Binding<Bool>
    private let message: ToastMessage

    init(
        isPresenting: Binding<Bool>,
        message: ToastMessage
    ) {
        self.isPresenting = isPresenting
        self.message = message
    }

    func body(content: Content) -> some View {
        content
            .toast(isPresenting: isPresenting, duration: message.duration, tapToDismiss: message.tapToDismiss) {
                AlertToast(
                    displayMode: .banner(.pop),
                    type: .systemImage(message.image, Colors.black),
                    title: message.title
                )
            }
    }
}

private struct OptionalMessageToastModifier: ViewModifier {
    @Binding var message: ToastMessage?

    init(message: Binding<ToastMessage?>) {
        _message = message
    }

    func body(content: Content) -> some View {
        content.modifier(
            ToastModifier(
                isPresenting: Binding(
                    get: { message != nil },
                    set: { showing in
                        if showing == false { message = nil }
                    }
                ),
                message: message ?? .empty()
            )
        )
    }
}

// MARK: - View Modifier

public extension View {
    func toast(
        isPresenting: Binding<Bool>,
        message: ToastMessage
    ) -> some View {
        modifier(ToastModifier(
            isPresenting: isPresenting,
            message: message
        ))
    }

    func toast(
        message: Binding<ToastMessage?>
    ) -> some View {
        modifier(OptionalMessageToastModifier(
            message: message
        ))
    }
}
