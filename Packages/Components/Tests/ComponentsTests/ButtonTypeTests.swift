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
    
    @Test
    func adoptiveGlassEffectWithErrorState() {
        #expect(ButtonType.adoptiveGlassEffect(StateViewType<String>.error(TestError())) == .adoptiveGlassEffect(.disabled))
        #expect(ButtonType.adoptiveGlassEffect(StateViewType<String>.error(TestError()), isDisabled: true) == .adoptiveGlassEffect(.disabled))
        #expect(ButtonType.adoptiveGlassEffect(StateViewType<String>.error(TestError()), isDisabled: false) == .adoptiveGlassEffect(.normal))
    }
    
    @Test
    func adoptiveGlassEffectWithDataState() {
        #expect(ButtonType.adoptiveGlassEffect(StateViewType<String>.data("test")) == .adoptiveGlassEffect(.normal))
        #expect(ButtonType.adoptiveGlassEffect(StateViewType<String>.data("test"), isDisabled: true) == .adoptiveGlassEffect(.disabled))
        #expect(ButtonType.adoptiveGlassEffect(StateViewType<String>.data("test"), isDisabled: false) == .adoptiveGlassEffect(.normal))
    }
    
    @Test
    func adoptiveGlassEffectWithLoadingState() {
        #expect(ButtonType.adoptiveGlassEffect(StateViewType<String>.loading) == .adoptiveGlassEffect(.loading(showProgress: true)))
        #expect(ButtonType.adoptiveGlassEffect(StateViewType<String>.loading, showProgress: false) == .adoptiveGlassEffect(.loading(showProgress: false)))
        #expect(ButtonType.adoptiveGlassEffect(StateViewType<String>.loading, isDisabled: true) == .adoptiveGlassEffect(.disabled))
    }
    
    @Test
    func adoptiveGlassEffectWithNoDataState() {
        #expect(ButtonType.adoptiveGlassEffect(StateViewType<String>.noData) == .adoptiveGlassEffect(.disabled))
        #expect(ButtonType.adoptiveGlassEffect(StateViewType<String>.noData, isDisabled: true) == .adoptiveGlassEffect(.disabled))
        #expect(ButtonType.adoptiveGlassEffect(StateViewType<String>.noData, isDisabled: true) == .adoptiveGlassEffect(.disabled))
    }
}

private struct TestError: Error {}