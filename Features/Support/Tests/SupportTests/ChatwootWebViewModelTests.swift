// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import SwiftUI
import WebKit
@testable import Support

@MainActor
struct ChatwootWebViewModelTests {

    @Test
    func navigationPolicy() {
        #expect(ChatwootWebViewModel.mock().navigationPolicy(for: URL(string: "https://support.gemwallet.com/chat")) == .allow)
        #expect(ChatwootWebViewModel.mock().navigationPolicy(for: URL(string: "https://google.com")) == .cancel)
        #expect(ChatwootWebViewModel.mock().navigationPolicy(for: nil) == .cancel)
    }
}

extension ChatwootWebViewModel {
    static func mock(
        baseUrl: URL = URL(string: "https://support.gemwallet.com")!
    ) -> ChatwootWebViewModel {
        ChatwootWebViewModel(
            websiteToken: "token",
            baseUrl: baseUrl,
            supportDeviceId: "device-id",
            isPresentingSupport: .constant(false)
        )
    }
}
