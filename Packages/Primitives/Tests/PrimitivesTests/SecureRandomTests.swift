import Testing
@testable import Primitives

struct SecureRandomTests {

    @Test
    func defaultLength() throws {
        let key = try SecureRandom.generateKey()
        #expect(key.count == 32)
    }

    @Test
    func uniqueness() throws {
        let key1 = try SecureRandom.generateKey()
        let key2 = try SecureRandom.generateKey()
        #expect(key1 != key2)
    }
}
