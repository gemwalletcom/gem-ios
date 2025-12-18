// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import PrimitivesTestKit
@testable import PrimitivesComponents

struct ToastMessageViewModelTests {

    @Test
    func toastMessage() {
        #expect(ToastMessageViewModel(type: .perpetualAutoclose).toastMessage.title == "Auto Close")
        #expect(ToastMessageViewModel(type: .perpetualClose).toastMessage.title == "Close position")
        #expect(ToastMessageViewModel(type: .perpetualOrder(.open(.mock(direction: .long)))).toastMessage.title == "Open Long")
        #expect(ToastMessageViewModel(type: .perpetualOrder(.open(.mock(direction: .short)))).toastMessage.title == "Open Short")
        #expect(ToastMessageViewModel(type: .perpetualOrder(.increase(.mock()))).toastMessage.title == "Increase Position")
        #expect(ToastMessageViewModel(type: .perpetualOrder(.reduce(.mock(), available: 0, positionDirection: .long))).toastMessage.title == "Reduce Position")
    }
}
