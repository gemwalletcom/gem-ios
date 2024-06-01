import Foundation
import Primitives
import WalletCore
import Keystore

public struct Signer {
    
    let wallet: Primitives.Wallet
    let keystore: any Keystore
    
    public init(
        wallet: Primitives.Wallet,
        keystore: any Keystore
    ) {
        self.wallet = wallet
        self.keystore = keystore
    }
    
    public func sign(input: SignerInput) throws -> String {
        let chain = input.asset.chain
        let privateKey = try keystore.getPrivateKey(wallet: wallet, chain: chain)
        let signer = signer(for: chain)
        
        switch input.type {
        case .transfer(let asset):
            switch asset.id.type {
            case .native:
                return try signer.signTransfer(input: input, privateKey: privateKey)
            case .token:
                return try signer.signTokenTransfer(input: input, privateKey: privateKey)
            }
        case .swap:
            return try signer.swap(input: input, privateKey: privateKey)
        case .generic:
            return try signer.signData(input: input, privateKey: privateKey)
        case .stake:
            return try signer.signStake(input: input, privateKey: privateKey)
        }
        
    }
    
    func signer(for chain: Chain) -> Signable {
        switch chain.type {
        case .solana:
            return SolanaSigner()
        case .ethereum:
            return EthereumSigner()
        case .cosmos:
            return CosmosSigner()
        case .ton:
            return TonSigner()
        case .tron:
            return TronSigner()
        case .bitcoin:
            return BitcoinSigner()
        case .aptos:
            return AptosSigner()
        case .sui:
            return SuiSigner()
        case .xrp:
            return XrpSigner()
        case .near:
            return NearSigner()
        }
    }
}
