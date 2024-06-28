// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public extension View {
    @ViewBuilder func isHidden(_ isHidden: Bool) -> some View {
        if isHidden {
            self.hidden()
        } else {
            self
        }
    }

    @ViewBuilder
    func `if`<Content: View>(
        _ condition: Bool,
        content: (Self) -> Content
    ) -> some View {
        self.ifElse(condition, ifContent: content, elseContent: { _ in self })
    }

    @ViewBuilder
    func ifElse<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        ifContent: (Self) -> TrueContent,
        elseContent: (Self) -> FalseContent
    ) -> some View {
        if condition {
            ifContent(self)
        } else {
            elseContent(self)
        }
    }
}

// MARK: - Confirmation Dialog

public extension View {
    func confirmationDialog<S, A, T>(
        _ title: S,
        presenting data: Binding<T?>,
        sensoryFeedback: SensoryFeedback,
        @ViewBuilder actions: (T) -> A)
    -> some View where S: StringProtocol, A: View {
        let isPresented: Binding<Bool> = Binding(
            get: {
                return data.wrappedValue != nil
            }, set: { newValue in
                guard !newValue else { return }
                data.wrappedValue = nil
            }
        )
        // confiramtion dialog works good only for iPhone, for different devices use a alert
        let iPhone = UIDevice.current.userInterfaceIdiom == .phone

        return ifElse(iPhone) {
            $0.confirmationDialog(
                    title,
                    isPresented: isPresented,
                    titleVisibility: .visible,
                    presenting: data.wrappedValue,
                    actions: actions
                )
        } elseContent: {
            $0.alert(
                    title,
                    isPresented: isPresented,
                    presenting: data.wrappedValue,
                    actions: actions
                )
        }
    }
}

