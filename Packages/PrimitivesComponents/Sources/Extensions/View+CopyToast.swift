// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components

public extension View {
    func copyToast(
        model: CopyTypeViewModel,
        isPresenting: Binding<Bool>,
        feedbackGenerator: UINotificationFeedbackGenerator = UINotificationFeedbackGenerator()
    ) -> some View {
        self.toast(
            isPresenting: isPresenting,
            title: model.message,
            systemImage: model.systemImage
        )
        .onChange(of: isPresenting.wrappedValue, initial: true) { oldValue, newValue in
            if newValue {
                UIPasteboard.general.string = model.copyValue
                feedbackGenerator.notificationOccurred(.success)
            }
        }
    }
}
