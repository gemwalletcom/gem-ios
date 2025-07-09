// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public struct AlertMessageModifier: ViewModifier {
    @Binding var alertMessage: AlertMessage?
    
    public func body(content: Content) -> some View {
        content
            .alert(
                alertMessage?.title ?? "",
                isPresented: $alertMessage.mappedToBool(),
                actions: {},
                message: { Text(alertMessage?.message ?? "") }
            )
    }
}

public extension View {
    func alertSheet(_ alertMessage: Binding<AlertMessage?>) -> some View {
        self.modifier(AlertMessageModifier(alertMessage: alertMessage))
    }
}