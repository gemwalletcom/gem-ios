import Testing
import Store
import WalletCore
import Primitives
import KeystoreTestKit
import PreferencesTestKit
import Preferences

@testable import Keystore

final class LocalKeystoreTests {

    @Test
    func testCreateWallet() {
        let keystore = LocalKeystore.mock()
        let createdWords = keystore.createWallet()
        #expect(createdWords.count == 12)
    }

    @Test
    func testImportWallet() {
        #expect(throws: Never.self) {
            let keystore = LocalKeystore.mock()
            let words = keystore.createWallet()
            #expect(keystore.wallets.count == 0)

            let _ = try keystore.importWallet(name: "test", type: .phrase(words: words, chains: [.ethereum]))
            #expect(keystore.wallets.count == 1)
        }
    }

    @Test
    func testImportSolanaWallet() {
        #expect(throws: Never.self) {
            let keystore = LocalKeystore.mock()
            let _ = try keystore.importWallet(name: "test", type: .phrase(words: LocalKeystore.words, chains: [.solana]))

            #expect(keystore.wallets.count == 1)
            #expect(keystore.wallets.first?.accounts.count == 1)
            #expect(keystore.wallets.first?.accounts.first?.address == "57mwmnV2rFuVDmhiJEjonD7cfuFtcaP9QvYNGfDEWK71")
        }
    }

    @Test
    func testImportEthereumWallet() {
        #expect(throws: Never.self) {
            let keystore = LocalKeystore.mock()
            let chains: [Chain] = [.ethereum, .smartChain, .blast]

            let _ = try keystore.importWallet(name: "test", type: .phrase(words: LocalKeystore.words, chains: chains))
            #expect(keystore.wallets.count == 1)
            #expect(keystore.wallets.first?.accounts == chains.map {
                Account(chain: $0,
                        address: "0x8f348F300873Fd5DA36950B2aC75a26584584feE",
                        derivationPath: "m/44'/60'/0'/0/0",
                        extendedPublicKey: "")
            })
        }
    }

    @Test
    func testExportSolanaPrivateKey() {
        #expect(throws: Never.self) {
            let keystore = LocalKeystore.mock()
            let hex = "0xb9095df5360714a69bc86ca92f6191e60355f206909982a8409f7b8358cf41b0"
            let wallet = try keystore.importWallet(name: "Test Solana", type: .privateKey(text: hex, chain: .solana))

            let exportedHex = try keystore.getPrivateKey(wallet: wallet, chain: .solana, encoding: .hex)
            let exportedBase58 = try keystore.getPrivateKey(wallet: wallet, chain: .solana, encoding: .base58)

            #expect(exportedHex == hex)
            #expect(exportedBase58 == "DTJi5pMtSKZHdkLX4wxwvjGjf2xwXx1LSuuUZhugYWDV")

            let keystore2 = LocalKeystore.mock()
            let wallet2 = try keystore2.importWallet(name: "Test Solana 2", type: .privateKey(text: exportedBase58, chain: .solana))
            let exportedKey = try keystore2.getPrivateKey(wallet: wallet2, chain: .solana)

            #expect(Base58.encodeNoCheck(data: exportedKey) == exportedBase58)
        }
    }

    @Test
    func testSignSolanaMessage() throws {
        let keystore = LocalKeystore.mock()
        let wallet = try keystore.importWallet(name: "Test Solana", type: .phrase(words: LocalKeystore.words, chains: [.solana]))

        let text = "5A2EYggC6hiAAuRArnkAANGySDyqQUGrbBHXfKQD9DQ5XcSkReDswnRqb7x3KRrnie9qSL"
        let message = SignMessage(type: .base58, data: Data(text.utf8))
        let signature = try keystore.sign(wallet: wallet, message: message, chain: .solana)
        let encoded = Base58.encodeNoCheck(data: signature)

        #expect(encoded == "5ZRaXVuDePowJjZmKaMjfcuqBVZet6e8QiCjTkGXBn7xhCvoEswUKXiGs2wmPxcqTfJUH28eCC91J1vLSjANNM9v")
    }

    @Test
    func testImportWIF() {
        #expect(throws: Never.self) {
            let wif = "L1NGZutRxaVotZSfRzGnFYUj42LjEL66ZdAeSDA8CbyASZWizHLA"
            let decoded = Base58.decode(string: wif)!
            #expect(decoded.count == 34)

            let key = decoded[1...32]
            #expect(PrivateKey.isValid(data: key, curve: .secp256k1))
        }
    }

    @Test
    func testDeriveAddress() {
        #expect(throws: Never.self) {
            let id = NSUUID().uuidString
            let keystore = LocalKeystore(
                folder: id,
                walletStore: .mock(),
                preferences: .mock(),
                keystorePassword: MockKeystorePassword()
            )

            let chains = Chain.allCases
            let wallet = try keystore.importWallet(name: "test", type: .phrase(words: LocalKeystore.words, chains: chains))

            #expect(keystore.wallets.count == 1)
            #expect(wallet.accounts.count == chains.count)

            for account in wallet.accounts {
                let chain = account.chain
                let derivedAddress = account.address
                let expected: String
                switch chain {
                case .bitcoin:
                    expected = "bc1quvuarfksewfeuevuc6tn0kfyptgjvwsvrprk9d"
                case .litecoin:
                    expected = "ltc1qhd8fxxp2dx3vsmpac43z6ev0kllm4n53t5sk0u"
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
                     .celo,
                     .world,
                     .sonic,
                     .abstract,
                     .berachain,
                     .ink,
                     .unichain,
                     .hyperliquid,
                     .monad:
                    expected = "0x8f348F300873Fd5DA36950B2aC75a26584584feE"
                case .solana:
                    expected = "57mwmnV2rFuVDmhiJEjonD7cfuFtcaP9QvYNGfDEWK71"
                case .thorchain:
                    expected = "thor1c8jd7ad9pcw4k3wkuqlkz4auv95mldr2kyhc65"
                case .cosmos:
                    expected = "cosmos142j9u5eaduzd7faumygud6ruhdwme98qsy2ekn"
                case .osmosis:
                    expected = "osmo142j9u5eaduzd7faumygud6ruhdwme98qclefqp"
                case .ton:
                    expected = "UQDgEMqToTacHic7SnvnPFmvceG5auFkCcAw0mSCvzvKUaT4"
                case .tron:
                    expected = "TQ5NMqJjhpQGK7YJbESKtNCo86PJ89ujio"
                case .doge:
                    expected = "DJRFZNg8jkUtjcpo2zJd92FUAzwRjitw6f"
                case .aptos:
                    expected = "0x7968dab936c1bad187c60ce4082f307d030d780e91e694ae03aef16aba73f30"
                case .sui:
                    expected = "0xada112cfb90b44ba889cc5d39ac2bf46281e4a91f7919c693bcd9b8323e81ed2"
                case .xrp:
                    expected = "rPwE3gChNKtZ1mhH3Ko8YFGqKmGRWLWXV3"
                case .celestia:
                    expected = "celestia142j9u5eaduzd7faumygud6ruhdwme98qpwmfv7"
                case .injective:
                    expected = "inj13u6g7vqgw074mgmf2ze2cadzvkz9snlwcrtq8a"
                case .sei:
                    expected = "sei142j9u5eaduzd7faumygud6ruhdwme98qagm0sj"
                case .noble:
                    expected = "noble142j9u5eaduzd7faumygud6ruhdwme98qc8l3wa"
                case .near:
                    expected = "0c91f6106ff835c0195d5388565a2d69e25038a7e23d26198f85caf6594117ec"
                case .stellar:
                    expected = "GA3H6I4C5XUBYGVB66KXR27JV5KS3APSTKRUWOIXZ5MVWZKVTLXWKZ2P"
                case .bitcoinCash:
                    expected = "qpzl3jxkzgvfd9flnd26leud5duv795fnv7vuaha70"
                case .algorand:
                    expected = "JTJWO524JXIHVPGBDWFLJE7XUIA32ECOZOBLF2QP3V5TQBT3NKZSCG67BQ"
                case .polkadot:
                    expected = "13nN6BGAoJwd7Nw1XxeBCx5YcBXuYnL94Mh7i3xBprqVSsFk"
                case .cardano:
                    expected = "addr1qyr8jjfnypp95eq74aqzn7ss687ehxclgj7mu6gratmg3mul2040vt35dypp042awzsjk5xm3zr3zm5qh7454uwdv08s84ray2"
                }

                #expect(derivedAddress == expected, "\(chain) failed to match address")
            }
        }
    }
}
