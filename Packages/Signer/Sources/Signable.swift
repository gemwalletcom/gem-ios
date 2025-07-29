import Foundation
import Primitives

public enum SignMessage {
    case typed(String)
}

public protocol Signable {
    func signData(input: SignerInput,privateKey: Data) throws -> String
    func signTransfer(input: SignerInput, privateKey: Data) throws -> String
    func signTokenTransfer(input: SignerInput, privateKey: Data) throws -> String
    func signNftTransfer(input: SignerInput, privateKey: Data) throws -> String
    func signSwap(input: SignerInput, privateKey: Data) throws -> [String]
    func signTokenApproval(input: SignerInput, privateKey: Data) throws -> String
    func signStake(input: SignerInput, privateKey: Data) throws -> [String]
    func signMessage(message: SignMessage, privateKey: Data) throws -> String
    func signAccountAction(input: SignerInput, privateKey: Data) throws -> String
    func signPerpetual(input: SignerInput, privateKey: Data) throws -> [String]
}

extension Signable {
    public func signTokenTransfer(input: SignerInput, privateKey: Data) throws -> String {
        throw AnyError("unimplemented")
    }
    
    public func signNftTransfer(input: SignerInput, privateKey: Data) throws -> String {
        throw AnyError("unimplemented")
    }
    
    public func signAccountAction(input: SignerInput, privateKey: Data) throws -> String {
        throw AnyError("unimplemented")
    }
    
    public func signData(input: Primitives.SignerInput, privateKey: Data) throws -> String {
        throw AnyError("unimplemented")
    }
    
    public func signSwap(input: SignerInput, privateKey: Data) throws -> [String] {
        throw AnyError("unimplemented")
    }
    
    public func signTokenApproval(input: SignerInput, privateKey: Data) throws -> String {
        throw AnyError("unimplemented")
    }
    
    public func signStake(input: SignerInput, privateKey: Data) throws -> [String] {
        throw AnyError("unimplemented")
    }
    
    public func signMessage(message: SignMessage, privateKey: Data) throws -> String {
        throw AnyError("unimplemented")
    }
    
    public func signPerpetual(input: SignerInput, privateKey: Data) throws -> [String] {
        throw AnyError("unimplemented")
    }
}
