import Foundation
import Gemstone
import WalletCore

final class NativeSigner: AlienSigner {
    func signEip712(typedDataJson: String, privateKey: Data) throws -> String {
        let hash = EthereumAbi.encodeTyped(messageJson: typedDataJson)
        guard let key = PrivateKey(data: privateKey), let signature = key.sign(digest: hash, curve: .secp256k1) else {
            throw AlienError.SigningError(msg: "Failed to sign EIP712 payload")
        }
        return signature.hexString.append0x
    }
}
