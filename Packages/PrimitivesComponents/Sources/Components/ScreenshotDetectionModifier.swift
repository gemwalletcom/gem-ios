// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Localization

struct ScreenshotDetectionModifier: ViewModifier {
    let docsUrl: URL

    @State private var showingAlert = false

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.userDidTakeScreenshotNotification)) { _ in
                showingAlert = true
            }
            .alert(
                Localized.SecretPhrase.ScreenshotDetected.title,
                isPresented: $showingAlert
            ) {
                Button(Localized.Common.learnMore) {
                    UIApplication.shared.open(docsUrl)
                }
                Button(Localized.Common.done, role: .cancel) { }
            } message: {
                Text(Localized.SecretPhrase.ScreenshotDetected.description)
            }
    }
}

public extension View {
    func detectScreenshots(docsUrl: URL) -> some View {
        modifier(ScreenshotDetectionModifier(docsUrl: docsUrl))
    }
}
