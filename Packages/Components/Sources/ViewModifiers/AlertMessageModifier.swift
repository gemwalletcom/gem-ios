// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public struct AlertMessageModifier: ViewModifier {
    @Binding var alertMessage: AlertMessage?
    
    public func body(content: Content) -> some View {
        content
            .alert(
                alertMessage?.title ?? "",
                isPresented: $alertMessage.mappedToBool(),
                actions: {
                    if let actions = alertMessage?.actions {
                        ForEach(0..<actions.count, id: \.self) { index in
                            let action = actions[index]
                            if action.isDefaultAction {
                                Button(action.title, role: action.role) {
                                    action.action()
                                }
                                .keyboardShortcut(.defaultAction)
                            } else {
                                Button(action.title, role: action.role) {
                                    action.action()
                                }
                            }
                        }
                    }
                },
                message: { Text(alertMessage?.message ?? "") }
            )
    }
}

public extension View {
    func alertSheet(_ alertMessage: Binding<AlertMessage?>) -> some View {
        self.modifier(AlertMessageModifier(alertMessage: alertMessage))
    }
}