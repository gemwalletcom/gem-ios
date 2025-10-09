import Foundation
import Primitives
import WalletCore
import Keystore
import Blockchain

public struct Signer: Sendable {
    
    let wallet: Primitives.Wallet
    let keystore: any Keystore
    
    public init(
        wallet: Primitives.Wallet,
        keystore: any Keystore
    ) {
        self.wallet = wallet
        self.keystore = keystore
    }
    
    func sign(input: SignerInput, chain: Chain, privateKey: Data) throws -> [String] {
        let signer = signer(for: chain)
        switch input.type {
        case .transfer(let asset), .deposit(let asset):
            switch asset.id.type {
            case .native:
                return [try signer.signTransfer(input: input, privateKey: privateKey)]
            case .token:
                return [try signer.signTokenTransfer(input: input, privateKey: privateKey)]
            }
        case .transferNft:
            return [try signer.signNftTransfer(input: input, privateKey: privateKey)]
        case .tokenApprove:
            return [try signer.signTokenTransfer(input: input, privateKey: privateKey)]
        case .swap:
            return try signer.signSwap(input: input, privateKey: privateKey)
        case .generic:
            return [try signer.signData(input: input, privateKey: privateKey)]
        case .stake:
            return try signer.signStake(input: input, privateKey: privateKey)
        case .account:
            return [try signer.signAccountAction(input: input, privateKey: privateKey)]
        case .perpetual:
            return try signer.signPerpetual(input: input, privateKey: privateKey)
        case .withdrawal:
            return [try signer.signWithdrawal(input: input, privateKey: privateKey)]
        }
    }

    public func sign(input: SignerInput) throws -> [String] {
        let chain = input.asset.chain
        let privateKey = try keystore.getPrivateKey(wallet: wallet, chain: chain)
        return try sign(input: input, chain: chain, privateKey: privateKey)
    }
    
    public func signMessage(chain: Chain, message: SignMessage) throws -> String {
        let privateKey = try keystore.getPrivateKey(wallet: wallet, chain: chain)
        return try signMessage(chain: chain, message: message, privateKey: privateKey)
    }
    
    public func signMessage(chain: Chain, message: SignMessage, privateKey: Data) throws -> String {
        return try signer(for: chain)
            .signMessage(message: message, privateKey: privateKey)
    }
    
    func signer(for chain: Chain) -> Signable {
        switch chain.type {
        case .solana: SolanaSigner()
        case .ethereum: EthereumSigner()
        case .cosmos: CosmosSigner()
        case .ton: TonSigner()
        case .tron: TronSigner()
        case .bitcoin: BitcoinSigner()
        case .aptos: AptosSigner()
        case .sui: SuiSigner()
        case .xrp: XrpSigner()
        case .near: NearSigner()
        case .stellar: StellarSigner()
        case .algorand: AlgorandSigner()
        case .polkadot: PolkadotSigner()
        case .cardano: CardanoSigner()
        case .hyperCore: HyperCoreSigner()
        }
    }
}
