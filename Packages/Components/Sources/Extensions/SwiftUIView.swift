// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

// MARK: - View builders

public extension View {
    @ViewBuilder func isHidden(_ isHidden: Bool) -> some View {
        if isHidden {
            self.hidden()
        } else {
            self
        }
    }
    
    @ViewBuilder func isVisible(_ isVisible: Bool) -> some View {
        if isVisible {
            self
        } else {
            self.hidden()
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

    @ViewBuilder
    func ifLet<Wrapped, Content: View>(
        _ optional: Wrapped?,
        content: (Self, Wrapped) -> Content
    ) -> some View {
        if let value = optional {
            content(self, value)
        } else {
            self
        }
    }

    @ViewBuilder
    func ifLet<Wrapped, TrueContent: View, FalseContent: View>(
        _ optional: Wrapped?,
        ifContent: (Self, Wrapped) -> TrueContent,
        elseContent: (Self) -> FalseContent
    ) -> some View {
        if let value = optional {
            ifContent(self, value)
        } else {
            elseContent(self)
        }
    }
}

// MARK: - Confirmation Dialog

public extension View {
    func confirmationDialog<S, A, T, M>(
        _ title: S,
        presenting data: Binding<T?>,
        sensoryFeedback: SensoryFeedback? = nil,
        @ViewBuilder actions: (T) -> A,
        @ViewBuilder message: () -> M = { EmptyView() }
    )
    -> some View where S: StringProtocol, A: View, M: View {
        let isPresented: Binding<Bool> = Binding(
            get: { data.wrappedValue != nil },
            set: { newValue in
                guard !newValue else { return }
                data.wrappedValue = nil
            }
        )
        // confiramtion dialog works good only for iPhone, for different devices use an alert
        let iPhone = UIDevice.current.userInterfaceIdiom == .phone

        return ifElse(iPhone) {
            $0.confirmationDialog(
                    title,
                    isPresented: isPresented,
                    titleVisibility: .visible,
                    presenting: data.wrappedValue,
                    actions: actions,
                    message: { _ in
                        message()
                    }
                )
        } elseContent: {
            $0.alert(
                    title,
                    isPresented: isPresented,
                    presenting: data.wrappedValue,
                    actions: actions,
                    message: { _ in
                        message()
                    }
                )
        }
        .ifLet(sensoryFeedback) { view, value in
            view.sensoryFeedback(value, trigger: isPresented.wrappedValue) { $1 }
        }
    }
}

// MARK: - Sheet

public extension View {
    func sheet<A, T>(
        presenting data: Binding<T?>,
        sensoryFeedback: SensoryFeedback? = nil,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (T) -> A
    ) -> some View where A: View {
        let isPresented = Binding<Bool>(
            get: { data.wrappedValue != nil },
            set: { newValue in
                guard !newValue else { return }
                data.wrappedValue = nil
            }
        )

        return sheet(
            isPresented: isPresented,
            onDismiss: onDismiss,
            content: {
                data.wrappedValue.map(content)
            }
        )
        .ifLet(sensoryFeedback) { view, value in
            view.sensoryFeedback(value, trigger: isPresented.wrappedValue) { $1 }
        }
    }
}
