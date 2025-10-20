import Foundation
import Gemstone
import WalletCore

final class NativeSigner: AlienSigner {
    func signEip712(typedDataJson: String, privateKey: Data) throws -> String {
        let digest = EthereumAbi.encodeTyped(messageJson: typedDataJson)
        let signer = GemstoneSigner()
        let signature = try signer.signDigest(algorithm: .secp256k1, digest: digest, privateKey: privateKey)
        return signature.hexString.append0x
    }
}
