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
    func solanaSwap() throws {
        let fromAsset = Asset(.solana).chain.asset
        let toAsset = Asset.mock(id: AssetId(chain: .solana, tokenId: "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB"))
        let swapData = SwapData(
            quote: SwapQuote(
                fromAddress: "K1tChn2NETQd9cCHe1UmUyWP3rDA92gP1dH4nNyEJrx",
                fromValue: "1000000",
                toAddress: "HVoJWyPbQn4XikG9BY2A8wP27HJQzHAoDnAs1SfsATes",
                toValue: "2000000",
                providerData: SwapProviderData(
                    provider: .jupiter,
                    name: "Jupiter",
                    protocolName: "jupiter"
                ),
                slippageBps: 50,
                etaInSeconds: 60,
                useMaxAmount: false
            ),
            data: SwapQuoteData(
                to: "HVoJWyPbQn4XikG9BY2A8wP27HJQzHAoDnAs1SfsATes",
                dataType: .transfer,
                value: "0",
                data: "AQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAQAIE4X7qT7inGBPqFijUWiMASkIQer7GcY6cKR108e8O++fF6bw89YHC7acs3m1YUIhVlGt8Lsh5HSIZozEPbcak9lEkZ+TiEMZdELfvcljcnBtv3Cf2z6oSYOBlVK0qYEJiVPvd6ryg3kqPlsEMcw3Fwx5sgoudurpYDKruhuxfayEdR478uf/smdZykpYhZIZWgIVX3IpDQW2WlWxw1AX3C53BHo4HDkVOPejukK6/oQdRT8m1S5xpmRD9q8e3XSK/Xu3TqNZNjLp6OSRg8r3sOv1e+QztSj31QG3tKRlT5zLqo0WQ1mJ0Hxkrw69L1dQmgMqgZd20xmPPvg53n23dsfNG6CPj/KUTsrekiJQc2Hvabji48RBleABXKq2lBKpj89u0FRUiC4li6CDgDgrZl6r6UV4hTXUW6fWb5yNguwg6dRIiwf+OZsakVXlghtpfUMBbAo8Tzu8oq+0HQFjMFcAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMGRm/lIRcy/+ytunLDm+e8jOW7xfcSayxDmzpAAAAABHnVW/IxwG7udMVuzmgVB/2xst6j9I5RArHNola8E48G3fbh12Whk9nL4UbO63msHLSF7V9bN5E6jPWFfv8AqYyXJY9OJInxuz0QKRSODYMLWhOZ2v8QhASOe9jb6fhZrBrj0IfykjcGJUj3DEwErsKplWlJhufLtGdSBiHThjC0P/on9df2SnTAmx8pWHneSwmrNt/J3VFLMhqns4zl6Mb6evO+2606PWXzaqvJdDGxu+TC0vbg5HymAgNFL11hhfF5aGC8uN+dIBDrxV3vHwZYs2RmFKm87C1HtO3e+NIHDAAFAsBcFQAPBgAJACwLDgEBCwIACQwCAAAAgJaYAAAAAAAOAQkBEQ8GAAYAEgsOAQENQg4QAAkFCgYsEgcNEQ0qKRYZCgUXGBArDg0nDi0uEAUhIgQfICYOHiUdGhsoHB4eHh4eHgQDECMOEBQDFQoTCAIBJDLBIJszQdacgQUEAAAAEgA8AAQDKAACB2QCAxEBZAMEgJaYAAAAAACBqQkAAAAAADIAMg4DCQAAAQkEB4tUBJUod+xdJHClaAbwfY0KcsPyS6puvinwAKI7S1cD9e7vBh7xJzZ/XBUMq/0+5x74cLXUfrm4RcW7GMg1vW5lr144gPYI6KKjBMO8u74DwL/CbfplXQ5y4uTDJAQIjShVPQLz8v+me8U9jJd68IPKjLkFvL08uLoAzNqZz4glI8qy5jvrpHYo8Vzh6SmqRgs5a0H2AAOFaZwE6uzp5wNl7es=",
                memo: nil,
                approval: nil,
                gasLimit: nil
            )
        )
        
        let input = SignerInput(
            type: .swap(fromAsset, toAsset, swapData),
            asset: fromAsset,
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
        
        let result = try SolanaSigner().signSwap(input: input, privateKey: TestPrivateKey)
        #expect(result.count == 1)
        #expect(!result[0].isEmpty)
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

    @Test
    func solanaRawTxDecoder() {
        let rawTx = "AgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADg8M2FRx269K+zS8zLnv1jrOc5UgDry1oYxecVoCE+FxaIlIE3LTCK5GF5CzCCSkyPQPR14YZsIa38Vu8zmewBgAIAAwuF+6k+4pxgT6hYo1FojAEpCEHq+xnGOnCkddPHvDvvnwoEJW7RK+RvTyYjTaEmmeJJGx7FDytUlV3phwhnLk/r+o7AIiuGV76I/RQwJmovrxVIVynZIDhgTTNAHNxKXKQMOlp0lJiwd9U+29PnQtf+c3R43jQldu6Ve4l4MJzRLHu3TqNZNjLp6OSRg8r3sOv1e+QztSj31QG3tKRlT5zLCWp06QMZwgS1uI/TJ/gwLpboVWOHBIESfT2odVamEF8olyekhrnZjIZzm9FeP8AkdfjUBFdj1PeKOYjOQQ5yIVmPLxjpjiM7L1AxMxqh2a/yjPk5ti2H8FK09PE9u6wRAwZGb+UhFzL/7K26csOb57yM5bvF9xJrLEObOkAAAACMlyWPTiSJ8bs9ECkUjg2DC1oTmdr/EIQEjnvY2+n4WQbd9uHXZaGT2cvhRs7reawctIXtX1s3kTqM9YV+/wCp0P5e0Steyi4OtRMALbRonjhrWQUnM3/sbCIGRwipaicFCAAJA4AaBgAAAAAACQcAAgMLDQoOAQEKAwQCAAkDgJaYAAAAAAAFBQADAgsNvAGP6/zC01qGTam9BJP5vR95KkrtwfmdVFNadaRsOP1WqPLGt8jXWBehgJaYAAAAAAAAAAAAAAAAAJF5EQAAAAAAAAAAAAAAAAAVAIk/g7omh1PrQHSTjRmxQaSVbGwIsUkg7qwrN0tYmJrlA5JYGB9c6sjb/7cDCJAkPK7WmpWZ0ohtlXqct2Vq872zKDwhDQAAAAAhh39oAAAAAJ1rmLGP0mte/uxo0CDc8b56lMLDFTU3ebxrOu1EGI3fMgUTAwIABQsGDxAREgcTDAEUFRYKDQiNNiXP7dL61wHZww37lhGNrgM1pfXVtOEebA/y8LN1Fi1I9ekUZZPYqwIREAopJw4LGgwPAwQg"
        let rawTxData = Data(base64Encoded: rawTx)!
        let decoder = SolanaRawTxDecoder(rawData: rawTxData)

        #expect(decoder.signatureCount() == 2)
    }
}
