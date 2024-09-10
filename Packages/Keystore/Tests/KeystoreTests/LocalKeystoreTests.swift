import XCTest
@testable import Keystore
import Store
import WalletCore
import Primitives
import KeystoreTestKit

final class LocalKeystoreTests: XCTestCase {

    // testing only phrase (from Wallet Core)
    let words = ["shoot", "island", "position", "soft", "burden", "budget", "tooth", "cruel", "issue", "economy", "destroy", "above"]
    
    func testCreateWallet() {
        let keystore = LocalKeystore.mock()
        
        XCTAssertEqual(keystore.createWallet().count, 12)
    }
    
    func testImportWallet() {
        let keystore = LocalKeystore.mock()
        let words = keystore.createWallet()

        XCTAssertEqual(keystore.wallets.count, 0)

        let _ = try! keystore.importWallet(name: "test", type: .phrase(words: words, chains: [.ethereum]))

        XCTAssertEqual(keystore.wallets.count, 1)
    }
    
    func testImportSolanaWallet() {
        let keystore = LocalKeystore.mock()
        let _ = try! keystore.importWallet(name: "test", type: .phrase(words: words, chains: [.solana]))

        XCTAssertEqual(keystore.wallets.count, 1)
        XCTAssertEqual(keystore.wallets.first?.accounts.count, 1)
        XCTAssertEqual(keystore.wallets.first?.accounts.first?.address, "57mwmnV2rFuVDmhiJEjonD7cfuFtcaP9QvYNGfDEWK71")
    }
    
    func testImportEthereumWallet() {
        let keystore = LocalKeystore.mock()
        let chains: [Chain] = [.ethereum, .smartChain, .blast]
        let _ = try! keystore.importWallet(name: "test", type: .phrase(words: words, chains: [.ethereum, .smartChain, .blast]))

        XCTAssertEqual(keystore.wallets.count, 1)
        XCTAssertEqual(keystore.wallets.first?.accounts, chains.map {
            Account(chain: $0, address: "0x8f348F300873Fd5DA36950B2aC75a26584584feE", derivationPath: "m/44\'/60\'/0\'/0/0", extendedPublicKey: "")
        })
    }

    func testExportSolanaPrivateKey() throws {
        let keystore = LocalKeystore.mock()
        let hex = "0xb9095df5360714a69bc86ca92f6191e60355f206909982a8409f7b8358cf41b0"
        let wallet = try keystore.importWallet(name: "Test Solana", type: .privateKey(text: hex, chain: .solana))

        let exportedHex = try keystore.getPrivateKey(wallet: wallet, chain: .solana, encoding: .hex)
        let exportedBase58 = try keystore.getPrivateKey(wallet: wallet, chain: .solana, encoding: .base58)

        XCTAssertEqual(exportedHex, hex)
        XCTAssertEqual(exportedBase58, "DTJi5pMtSKZHdkLX4wxwvjGjf2xwXx1LSuuUZhugYWDV")

        let keystore2 = LocalKeystore.mock()
        let wallet2 = try keystore2.importWallet(name: "Test Solana 2", type: .privateKey(text: exportedBase58, chain: .solana))
        let exportedKey = try keystore2.getPrivateKey(wallet: wallet2, chain: .solana)

        XCTAssertEqual(Base58.encodeNoCheck(data: exportedKey), exportedBase58)
    }

    func testImportWIF() throws {
        let wif = "L1NGZutRxaVotZSfRzGnFYUj42LjEL66ZdAeSDA8CbyASZWizHLA"
        let decoded = Base58.decode(string: wif)!

        XCTAssertEqual(decoded.count, 34)

        let key = decoded[1...32] // skip prefix / compression flag

        XCTAssertTrue(PrivateKey.isValid(data: key, curve: .secp256k1))
    }

    func testDeriveAddress() {
        let id = NSUUID().uuidString
        let keystore = LocalKeystore(
            folder: id,
            walletStore: WalletStore(db: DB(path: "\(id).sqlite")),
            preferences: Preferences(),
            keystorePassword: MockKeystorePassword()
        )
        
        let chains = Chain.allCases
        let wallet = try! keystore.importWallet(name: "test", type: .phrase(words: words, chains: chains))
        
        XCTAssertEqual(keystore.wallets.count, 1)
        
        for account in wallet.accounts {
            let chain = account.chain
            switch chain {
            case .bitcoin:
                assertAddress(chain, "bc1quvuarfksewfeuevuc6tn0kfyptgjvwsvrprk9d", account.address)
            case .litecoin:
                assertAddress(chain, "ltc1qhd8fxxp2dx3vsmpac43z6ev0kllm4n53t5sk0u", account.address)
            case .ethereum,
                .smartChain,
                .polygon,
                .arbitrum,
                .optimism,
                .base,
                .avalancheC,
                .opBNB,
                .fantom,
                .gnosis,
                .manta,
                .blast,
                .zkSync,
                .linea,
                .mantle,
                .celo:
                assertAddress(chain, "0x8f348F300873Fd5DA36950B2aC75a26584584feE", account.address)
            case .solana:
                assertAddress(chain, "57mwmnV2rFuVDmhiJEjonD7cfuFtcaP9QvYNGfDEWK71", account.address)
            case .thorchain:
                assertAddress(chain, "thor1c8jd7ad9pcw4k3wkuqlkz4auv95mldr2kyhc65", account.address)
            case .cosmos:
                assertAddress(chain, "cosmos142j9u5eaduzd7faumygud6ruhdwme98qsy2ekn", account.address)
            case .osmosis:
                assertAddress(chain, "osmo142j9u5eaduzd7faumygud6ruhdwme98qclefqp", account.address)
            case .ton:
                assertAddress(chain, "UQDgEMqToTacHic7SnvnPFmvceG5auFkCcAw0mSCvzvKUaT4", account.address)
            case .tron:
                assertAddress(chain, "TQ5NMqJjhpQGK7YJbESKtNCo86PJ89ujio", account.address)
            case .doge:
                assertAddress(chain, "DJRFZNg8jkUtjcpo2zJd92FUAzwRjitw6f", account.address)
            case .aptos:
                assertAddress(chain, "0x7968dab936c1bad187c60ce4082f307d030d780e91e694ae03aef16aba73f30", account.address)
            case .sui:
                assertAddress(chain, "0xada112cfb90b44ba889cc5d39ac2bf46281e4a91f7919c693bcd9b8323e81ed2", account.address)
            case .xrp:
                assertAddress(chain, "rPwE3gChNKtZ1mhH3Ko8YFGqKmGRWLWXV3", account.address)
            case .celestia:
                assertAddress(chain, "celestia142j9u5eaduzd7faumygud6ruhdwme98qpwmfv7", account.address)
            case .injective:
                assertAddress(chain, "inj13u6g7vqgw074mgmf2ze2cadzvkz9snlwcrtq8a", account.address)
            case .sei:
                assertAddress(chain, "sei142j9u5eaduzd7faumygud6ruhdwme98qagm0sj", account.address)
            case .noble:
                assertAddress(chain, "noble142j9u5eaduzd7faumygud6ruhdwme98qc8l3wa", account.address)
            case .near:
                assertAddress(chain, "0c91f6106ff835c0195d5388565a2d69e25038a7e23d26198f85caf6594117ec", account.address)
            }
        }
        
        XCTAssertEqual(wallet.accounts.count, chains.count)
    }
    
    private func assertAddress(_ chain: Chain, _ expected: String, _ derivedAddress: String) {
        XCTAssertEqual(expected, derivedAddress, "\(chain) failed to match address")
    }
}

