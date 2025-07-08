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
        toast(isPresenting: isPresenting, message: ToastMessage(title: model.message, image: model.systemImage))
            .onChange(of: isPresenting.wrappedValue, initial: true) { oldValue, newValue in
                if newValue {
                    model.copy()
                    feedbackGenerator.notificationOccurred(.success)
                }
            }
    }
}
