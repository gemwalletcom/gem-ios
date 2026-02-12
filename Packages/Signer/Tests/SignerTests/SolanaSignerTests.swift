// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import PrimitivesTestKit
@testable import Signer
import Testing
import WalletCore

struct SolanaSignerTests {
    let fee = Fee(fee: .zero, gasPriceType: .solana(gasPrice: 5_000, priorityFee: 10_000, unitPrice: 200), gasLimit: 125_000)

    @Test
    func testTransfer() throws {
        let asset = Asset(.solana).chain.asset
        let input = SignerInput(
            type: .transfer(asset),
            asset: asset,
            value: .zero,
            fee: fee,
            isMaxAmount: false,
            memo: .none,
            senderAddress: "K1tChn2NETQd9cCHe1UmUyWP3rDA92gP1dH4nNyEJrx",
            destinationAddress: "HVoJWyPbQn4XikG9BY2A8wP27HJQzHAoDnAs1SfsATes",
            metadata: .solana(
                senderTokenAddress: nil,
                recipientTokenAddress: nil,
                tokenProgram: nil,
                blockHash: "8ntZRPm8pbf4R4pTWsVnTdgqXA35yYXSz8TxUzwBhXEK"
            )
        )

        let result = try SolanaSigner().signTransfer(input: input, privateKey: TestPrivateKey)
        #expect(result == "AQ+bcpkOGB15GeVJxnh3F9oQmLUf98OkLMonJusdLm85R2ukxnqgd6OmmP1XgBUL7GbN4t2jRJsOQOGiQkEcVwsBAAIE02lFIZfCpWSB5eLT6L8D3iNJ9npjFRlWgiIIwjNK3uL1G5t56F3oMXO9/md9Dan95RdKnFZ/h5iqL/+hVtYYxAMGRm/lIRcy/+ytunLDm+e8jOW7xfcSayxDmzpAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABzwz4o6+Cji9oIdB7FElRcPSFxAzYV8cPxQk26SYaknAMCAAkDyAAAAAAAAAACAAUCSOgBAAMCAAEMAgAAAAAAAAAAAAAA")
    }

    @Test
    func tokenTransfer() throws {
        let asset = Asset.mock(id: AssetId(chain: .solana, tokenId: "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB"))
        let input = SignerInput(
            type: .transfer(asset),
            asset: asset,
            value: .zero,
            fee: fee,
            isMaxAmount: false,
            memo: .none,
            senderAddress: "K1tChn2NETQd9cCHe1UmUyWP3rDA92gP1dH4nNyEJrx",
            destinationAddress: "HVoJWyPbQn4XikG9BY2A8wP27HJQzHAoDnAs1SfsATes",
            metadata: .solana(
                senderTokenAddress: nil,
                recipientTokenAddress: nil,
                tokenProgram: nil,
                blockHash: "8ntZRPm8pbf4R4pTWsVnTdgqXA35yYXSz8TxUzwBhXEK"
            )
        )

        let result = try SolanaSigner().signTransfer(input: input, privateKey: TestPrivateKey)
        #expect(result == "AQ+bcpkOGB15GeVJxnh3F9oQmLUf98OkLMonJusdLm85R2ukxnqgd6OmmP1XgBUL7GbN4t2jRJsOQOGiQkEcVwsBAAIE02lFIZfCpWSB5eLT6L8D3iNJ9npjFRlWgiIIwjNK3uL1G5t56F3oMXO9/md9Dan95RdKnFZ/h5iqL/+hVtYYxAMGRm/lIRcy/+ytunLDm+e8jOW7xfcSayxDmzpAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABzwz4o6+Cji9oIdB7FElRcPSFxAzYV8cPxQk26SYaknAMCAAkDyAAAAAAAAAACAAUCSOgBAAMCAAEMAgAAAAAAAAAAAAAA")
    }

    @Test
    func tokenTransferNewAccount() throws {
        let asset = Asset.mock(id: AssetId(chain: .solana, tokenId: "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB"))
        let input = SignerInput(
            type: .transfer(asset),
            asset: asset,
            value: .zero,
            fee: fee,
            isMaxAmount: false,
            memo: .none,
            senderAddress: "K1tChn2NETQd9cCHe1UmUyWP3rDA92gP1dH4nNyEJrx",
            destinationAddress: "HVoJWyPbQn4XikG9BY2A8wP27HJQzHAoDnAs1SfsATes",
            metadata: .solana(
                senderTokenAddress: "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB",
                recipientTokenAddress: "8ntZRPm8pbf4R4pTWsVnTdgqXA35yYXSz8TxUzwBhXEK",
                tokenProgram: .token,
                blockHash: "8ntZRPm8pbf4R4pTWsVnTdgqXA35yYXSz8TxUzwBhXEK"
            )
        )

        let result = try SolanaSigner().signTransfer(input: input, privateKey: TestPrivateKey)
        #expect(result == "AQ+bcpkOGB15GeVJxnh3F9oQmLUf98OkLMonJusdLm85R2ukxnqgd6OmmP1XgBUL7GbN4t2jRJsOQOGiQkEcVwsBAAIE02lFIZfCpWSB5eLT6L8D3iNJ9npjFRlWgiIIwjNK3uL1G5t56F3oMXO9/md9Dan95RdKnFZ/h5iqL/+hVtYYxAMGRm/lIRcy/+ytunLDm+e8jOW7xfcSayxDmzpAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABzwz4o6+Cji9oIdB7FElRcPSFxAzYV8cPxQk26SYaknAMCAAkDyAAAAAAAAAACAAUCSOgBAAMCAAEMAgAAAAAAAAAAAAAA")
    }

    @Test
    func signSolanaMessage() {
        let keyData = Base58.decodeNoCheck(string: "G282j1ejo5LbL4DqBR4G5i9EQZk1FPZa2ZR4VE9x6JaHqfie3nrrgcGL6UXLfXrappiPnWSWK5F1kz3Xduoy57H")!
        let key = PrivateKey(data: keyData[0 ..< 32])!
        let pubKey = key.getPublicKeyEd25519()

        #expect(pubKey.data == keyData[32...])

        let message = "hello world"
        let dataMessage = message.data(using: .utf8)!

        let sig = key.sign(digest: dataMessage, curve: .ed25519)!
        let b58Sig = Base58.encodeNoCheck(data: sig)

        #expect(pubKey.verify(signature: sig, message: dataMessage))
        #expect(b58Sig == "2gK63KVgpUMjT612P2iyL1TCZx5zmwbXjNMQ9PqkVrLsUpNuPWUhJhGLp4puzXu87AoNtMASkzziUJmkKCv3wESR")
    }

}
