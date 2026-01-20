// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

struct ToastModifier: ViewModifier {
    private var isPresenting: Binding<Bool>

    private let message: ToastMessage
    private let duration: TimeInterval
    private let tapToDismiss: Bool
    private let offsetY: CGFloat

    init(
        isPresenting: Binding<Bool>,
        message: ToastMessage,
        duration: TimeInterval,
        tapToDismiss: Bool,
        offsetY: CGFloat
    ) {
        self.isPresenting = isPresenting
        self.message = message
        self.duration = duration
        self.tapToDismiss = tapToDismiss
        self.offsetY = offsetY
    }

    func body(content: Content) -> some View {
        content
            .toast(isPresenting: isPresenting, duration: duration, tapToDismiss: tapToDismiss, offsetY: offsetY) {
                AlertToast(
                    systemImage: message.image,
                    imageColor: Colors.black,
                    title: message.title
                )
            }
    }
}

private struct OptionalMessageToastModifier: ViewModifier {
    @Binding var message: ToastMessage?
    private let duration: TimeInterval
    private let tapToDismiss: Bool
    private let offsetY: CGFloat

    init(message: Binding<ToastMessage?>, duration: TimeInterval, tapToDismiss: Bool, offsetY: CGFloat) {
        _message = message
        self.duration = duration
        self.tapToDismiss = tapToDismiss
        self.offsetY = offsetY
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
                tapToDismiss: tapToDismiss,
                offsetY: offsetY
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
        duration: TimeInterval = Self.toastDuration,
        tapToDismiss: Bool = true,
        offsetY: CGFloat = 0
    ) -> some View {
        modifier(ToastModifier(
            isPresenting: isPresenting,
            message: message,
            duration: duration,
            tapToDismiss: tapToDismiss,
            offsetY: offsetY
        ))
    }

    func toast(
        message: Binding<ToastMessage?>,
        duration: TimeInterval = Self.toastDuration,
        tapToDismiss: Bool = true,
        offsetY: CGFloat = 0
    ) -> some View {
        modifier(OptionalMessageToastModifier(
            message: message,
            duration: duration,
            tapToDismiss: tapToDismiss,
            offsetY: offsetY
        ))
    }
}
