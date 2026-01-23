import Foundation
import Testing
@testable import Primitives

struct SecretDataTests {

    @Test
    func string() {
        #expect(SecretData(Data("hello".utf8)).string == "hello")
        #expect(SecretData(string: "secret").string == "secret")
        #expect(SecretData(words: ["one", "two", "three"]).string == "one two three")
    }

    @Test
    func words() {
        #expect(SecretData(string: "one two three").words == ["one", "two", "three"])
        #expect(SecretData(words: ["a", "b"]).words == ["a", "b"])
    }

    @Test
    func equatable() {
        #expect(SecretData(string: "same") == SecretData(string: "same"))
        #expect(SecretData(string: "a") != SecretData(string: "b"))
        #expect(SecretData(string: "test").hashValue == SecretData(string: "test").hashValue)
    }
}
