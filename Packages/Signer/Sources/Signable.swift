import Foundation
import Primitives

public protocol Signable {
    func signData(input: SignerInput,privateKey: Data) throws -> String
    func signTransfer(input: SignerInput, privateKey: Data) throws -> String
    func signTokenTransfer(input: SignerInput, privateKey: Data) throws -> String
    func swap(input: SignerInput, privateKey: Data) throws -> String
    func signStake(input: SignerInput, privateKey: Data) throws -> String
}
