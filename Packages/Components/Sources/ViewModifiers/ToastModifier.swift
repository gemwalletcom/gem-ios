// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

struct ToastModifier: ViewModifier {
    private var isPresenting: Binding<Bool>

    private let message: ToastMessage
    private let duration: Double
    private let tapToDismiss: Bool

    init(
        isPresenting: Binding<Bool>,
        message: ToastMessage,
        duration: Double,
        tapToDismiss: Bool
    ) {
        self.isPresenting = isPresenting
        self.message = message
        self.duration = duration
        self.tapToDismiss = tapToDismiss
    }

    func body(content: Content) -> some View {
        content
            .toast(isPresenting: isPresenting, duration: duration, tapToDismiss: tapToDismiss) {
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
    private let duration: Double
    private let tapToDismiss: Bool
    
    init(message: Binding<ToastMessage?>, duration: Double, tapToDismiss: Bool) {
        _message = message
        self.duration = duration
        self.tapToDismiss = tapToDismiss
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
                message: message ?? .empty(),
                duration: duration,
                tapToDismiss: tapToDismiss
            )
        )
    }
}

// MARK: - View Modifier

public extension View {
    static var toastDuration: Double { 2 }

    func toast(
        isPresenting: Binding<Bool>,
        message: ToastMessage,
        duration: Double = Self.toastDuration,
        tapToDismiss: Bool = true
    ) -> some View {
        modifier(ToastModifier(
            isPresenting: isPresenting,
            message: message,
            duration: duration,
            tapToDismiss: tapToDismiss
        ))
    }

    func toast(
        message: Binding<ToastMessage?>,
        duration: Double = Self.toastDuration,
        tapToDismiss: Bool = true
    ) -> some View {
        modifier(OptionalMessageToastModifier(
            message: message,
            duration: duration,
            tapToDismiss: tapToDismiss
        ))
    }
}
