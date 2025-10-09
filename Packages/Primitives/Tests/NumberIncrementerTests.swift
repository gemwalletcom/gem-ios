import Testing
@testable import Primitives

struct NumberIncrementerTests {
    
    @Test
    func incrementsFromZero() {
        let incrementer = NumberIncrementer(0)
        
        #expect(incrementer.next() == 0)
        #expect(incrementer.next() == 1)
    }
    
    @Test
    func incrementsFromTimestamp() {
        let timestamp = 1704067200
        let incrementer = NumberIncrementer(timestamp)
        
        #expect(incrementer.next() == 1704067200)
        #expect(incrementer.next() == 1704067201)
    }
}