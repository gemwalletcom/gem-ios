// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Style

@testable import Components

struct ButtonTypeTests {
    
    @Test
    func primaryWithErrorState() {
        #expect(ButtonType.primary(StateViewType<String>.error(TestError())) == .primary(.disabled))
        #expect(ButtonType.primary(StateViewType<String>.error(TestError()), isDisabled: true) == .primary(.disabled))
        #expect(ButtonType.primary(StateViewType<String>.error(TestError()), isDisabled: false) == .primary(.normal))
    }
    
    @Test
    func primaryWithDataState() {
        #expect(ButtonType.primary(StateViewType<String>.data("test")) == .primary(.normal))
        #expect(ButtonType.primary(StateViewType<String>.data("test"), isDisabled: true) == .primary(.disabled))
        #expect(ButtonType.primary(StateViewType<String>.data("test"), isDisabled: false) == .primary(.normal))
    }
    
    @Test
    func primaryWithLoadingState() {
        #expect(ButtonType.primary(StateViewType<String>.loading) == .primary(.loading(showProgress: true)))
        #expect(ButtonType.primary(StateViewType<String>.loading, showProgress: false) == .primary(.loading(showProgress: false)))
        #expect(ButtonType.primary(StateViewType<String>.loading, isDisabled: true) == .primary(.disabled))
    }
    
    @Test
    func primaryWithNoDataState() {
        #expect(ButtonType.primary(StateViewType<String>.noData) == .primary(.disabled))
        #expect(ButtonType.primary(StateViewType<String>.noData, isDisabled: true) == .primary(.disabled))
        #expect(ButtonType.primary(StateViewType<String>.noData, isDisabled: true) == .primary(.disabled))
    }
}

private struct TestError: Error {}
