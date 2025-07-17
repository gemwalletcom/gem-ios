// Copyright (c). Gem Wallet. All rights reserved.

import Testing
@testable import DeviceService

struct SerialExecutorTests {
    
    @Test
    func executeReturnsValue() async throws {
        let executor = SerialExecutor()
        
        let result = try await executor.execute { 42 }
        
        #expect(result == 42)
    }
    
    @Test
    func executeThrowsError() async throws {
        struct TestError: Error {}
        let executor = SerialExecutor()
        
        await #expect(throws: TestError.self) {
            try await executor.execute { throw TestError() }
        }
    }
    
    @Test
    func executeSerially() async throws {
        let executor = SerialExecutor()
        let counter = Counter()
        
        async let _ = executor.execute { await counter.increment() }
        async let _ = executor.execute { await counter.increment() }
        async let result = executor.execute { await counter.value }
        
        #expect(try await result == 2)
    }
}

actor Counter {
    private var count = 0
    
    func increment() {
        count += 1
    }
    
    var value: Int {
        count
    }
}