// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import WalletCore
@testable import Signer
import Primitives
import PrimitivesTestKit

final class SolanaSignerTests {

    let fee = Fee(fee: .zero, gasPriceType: .eip1559(gasPrice: 5_000, priorityFee: 10_000), gasLimit: 125_000)

    @Test
    func testTransfer() throws {
        let asset = Asset(.solana).chain.asset
        let input = SignerInput(
            type: .transfer(asset),
            asset: asset,
            value: .zero,
            fee: fee,
            isMaxAmount: false,
            chainId: "",
            memo: .none,
            accountNumber: 0,
            sequence: 0,
            senderAddress: "K1tChn2NETQd9cCHe1UmUyWP3rDA92gP1dH4nNyEJrx",
            destinationAddress: "HVoJWyPbQn4XikG9BY2A8wP27HJQzHAoDnAs1SfsATes",
            data: .none,
            block: SignerInputBlock(hash: "8ntZRPm8pbf4R4pTWsVnTdgqXA35yYXSz8TxUzwBhXEK"),
            token: SignerInputToken(),
            utxos: [],
            messageBytes: ""
        )

        let result = try SolanaSigner().signTransfer(input: input, privateKey: TestPrivateKey)
        #expect(result == "AQo2Eug/J7WNOj0pI72OU0RHM9Ss4OXK2HvuGhaKGhJN8KtcxIuEvAbuKuzjBfq+d6q8SfeVx8l6BOfYs0/lsQoBAAIE02lFIZfCpWSB5eLT6L8D3iNJ9npjFRlWgiIIwjNK3uL1G5t56F3oMXO9/md9Dan95RdKnFZ/h5iqL/+hVtYYxAMGRm/lIRcy/+ytunLDm+e8jOW7xfcSayxDmzpAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABzwz4o6+Cji9oIdB7FElRcPSFxAzYV8cPxQk26SYaknAMCAAkDECcAAAAAAAACAAUCSOgBAAMCAAEMAgAAAAAAAAAAAAAA")
    }

    @Test
    func testTokenTransfer() throws {
        let asset = Asset.mock(id: AssetId(chain: .solana, tokenId: "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB"))
        let input = SignerInput(
            type: .transfer(asset),
            asset: asset,
            value: .zero,
            fee: fee,
            isMaxAmount: false,
            chainId: "",
            memo: .none,
            accountNumber: 0,
            sequence: 0,
            senderAddress: "K1tChn2NETQd9cCHe1UmUyWP3rDA92gP1dH4nNyEJrx",
            destinationAddress: "HVoJWyPbQn4XikG9BY2A8wP27HJQzHAoDnAs1SfsATes",
            data: .none,
            block: SignerInputBlock(hash: "8ntZRPm8pbf4R4pTWsVnTdgqXA35yYXSz8TxUzwBhXEK"),
            token: SignerInputToken(),
            utxos: [],
            messageBytes: ""
        )

        let result = try SolanaSigner().signTransfer(input: input, privateKey: TestPrivateKey)
        #expect(result == "AQo2Eug/J7WNOj0pI72OU0RHM9Ss4OXK2HvuGhaKGhJN8KtcxIuEvAbuKuzjBfq+d6q8SfeVx8l6BOfYs0/lsQoBAAIE02lFIZfCpWSB5eLT6L8D3iNJ9npjFRlWgiIIwjNK3uL1G5t56F3oMXO9/md9Dan95RdKnFZ/h5iqL/+hVtYYxAMGRm/lIRcy/+ytunLDm+e8jOW7xfcSayxDmzpAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABzwz4o6+Cji9oIdB7FElRcPSFxAzYV8cPxQk26SYaknAMCAAkDECcAAAAAAAACAAUCSOgBAAMCAAEMAgAAAAAAAAAAAAAA")

    }

    @Test
    func testTokenTransferNewAccount() throws {
        let asset = Asset.mock(id: AssetId(chain: .solana, tokenId: "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB"))
        let input = SignerInput(
            type: .transfer(asset),
            asset: asset,
            value: .zero,
            fee: fee,
            isMaxAmount: false,
            chainId: "",
            memo: .none,
            accountNumber: 0,
            sequence: 0,
            senderAddress: "K1tChn2NETQd9cCHe1UmUyWP3rDA92gP1dH4nNyEJrx",
            destinationAddress: "HVoJWyPbQn4XikG9BY2A8wP27HJQzHAoDnAs1SfsATes",
            data: .none,
            block: SignerInputBlock(hash: "8ntZRPm8pbf4R4pTWsVnTdgqXA35yYXSz8TxUzwBhXEK"),
            token: SignerInputToken(senderTokenAddress: "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB", recipientTokenAddress: "8ntZRPm8pbf4R4pTWsVnTdgqXA35yYXSz8TxUzwBhXEK", tokenProgram: .token),
            utxos: [],
            messageBytes: ""
        )

        let result = try SolanaSigner().signTransfer(input: input, privateKey: TestPrivateKey)
        #expect(result == "AQo2Eug/J7WNOj0pI72OU0RHM9Ss4OXK2HvuGhaKGhJN8KtcxIuEvAbuKuzjBfq+d6q8SfeVx8l6BOfYs0/lsQoBAAIE02lFIZfCpWSB5eLT6L8D3iNJ9npjFRlWgiIIwjNK3uL1G5t56F3oMXO9/md9Dan95RdKnFZ/h5iqL/+hVtYYxAMGRm/lIRcy/+ytunLDm+e8jOW7xfcSayxDmzpAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABzwz4o6+Cji9oIdB7FElRcPSFxAzYV8cPxQk26SYaknAMCAAkDECcAAAAAAAACAAUCSOgBAAMCAAEMAgAAAAAAAAAAAAAA")
    }

    @Test
    func testSolanaSwap() {
        let tx = "AQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAQAIE4X7qT7inGBPqFijUWiMASkIQer7GcY6cKR108e8O++fF6bw89YHC7acs3m1YUIhVlGt8Lsh5HSIZozEPbcak9lEkZ+TiEMZdELfvcljcnBtv3Cf2z6oSYOBlVK0qYEJiVPvd6ryg3kqPlsEMcw3Fwx5sgoudurpYDKruhuxfayEdR478uf/smdZykpYhZIZWgIVX3IpDQW2WlWxw1AX3C53BHo4HDkVOPejukK6/oQdRT8m1S5xpmRD9q8e3XSK/Xu3TqNZNjLp6OSRg8r3sOv1e+QztSj31QG3tKRlT5zLqo0WQ1mJ0Hxkrw69L1dQmgMqgZd20xmPPvg53n23dsfNG6CPj/KUTsrekiJQc2Hvabji48RBleABXKq2lBKpj89u0FRUiC4li6CDgDgrZl6r6UV4hTXUW6fWb5yNguwg6dRIiwf+OZsakVXlghtpfUMBbAo8Tzu8oq+0HQFjMFcAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMGRm/lIRcy/+ytunLDm+e8jOW7xfcSayxDmzpAAAAABHnVW/IxwG7udMVuzmgVB/2xst6j9I5RArHNola8E48G3fbh12Whk9nL4UbO63msHLSF7V9bN5E6jPWFfv8AqYyXJY9OJInxuz0QKRSODYMLWhOZ2v8QhASOe9jb6fhZrBrj0IfykjcGJUj3DEwErsKplWlJhufLtGdSBiHThjC0P/on9df2SnTAmx8pWHneSwmrNt/J3VFLMhqns4zl6Mb6evO+2606PWXzaqvJdDGxu+TC0vbg5HymAgNFL11hhfF5aGC8uN+dIBDrxV3vHwZYs2RmFKm87C1HtO3e+NIHDAAFAsBcFQAPBgAJACwLDgEBCwIACQwCAAAAgJaYAAAAAAAOAQkBEQ8GAAYAEgsOAQENQg4QAAkFCgYsEgcNEQ0qKRYZCgUXGBArDg0nDi0uEAUhIgQfICYOHiUdGhsoHB4eHh4eHgQDECMOEBQDFQoTCAIBJDLBIJszQdacgQUEAAAAEgA8AAQDKAACB2QCAxEBZAMEgJaYAAAAAACBqQkAAAAAADIAMg4DCQAAAQkEB4tUBJUod+xdJHClaAbwfY0KcsPyS6puvinwAKI7S1cD9e7vBh7xJzZ/XBUMq/0+5x74cLXUfrm4RcW7GMg1vW5lr144gPYI6KKjBMO8u74DwL/CbfplXQ5y4uTDJAQIjShVPQLz8v+me8U9jJd68IPKjLkFvL08uLoAzNqZz4glI8qy5jvrpHYo8Vzh6SmqRgs5a0H2AAOFaZwE6uzp5wNl7es="
        let bytes = Base64.decode(string: tx)!
        let message = bytes[65...]

        #expect(bytes[0] == 1)
        #expect(message.hexString == "800100081385fba93ee29c604fa858a351688c01290841eafb19c63a70a475d3c7bc3bef9f17a6f0f3d6070bb69cb379b56142215651adf0bb21e47488668cc43db71a93d944919f938843197442dfbdc96372706dbf709fdb3ea84983819552b4a981098953ef77aaf283792a3e5b0431cc37170c79b20a2e76eae96032abba1bb17dac84751e3bf2e7ffb26759ca4a588592195a02155f72290d05b65a55b1c35017dc2e77047a381c391538f7a3ba42bafe841d453f26d52e71a66443f6af1edd748afd7bb74ea3593632e9e8e49183caf7b0ebf57be433b528f7d501b7b4a4654f9ccbaa8d16435989d07c64af0ebd2f57509a032a819776d3198f3ef839de7db776c7cd1ba08f8ff2944ecade9222507361ef69b8e2e3c44195e0015caab69412a98fcf6ed05454882e258ba08380382b665eabe945788535d45ba7d66f9c8d82ec20e9d4488b07fe399b1a9155e5821b697d43016c0a3c4f3bbca2afb41d0163305700000000000000000000000000000000000000000000000000000000000000000306466fe5211732ffecadba72c39be7bc8ce5bbc5f7126b2c439b3a400000000479d55bf231c06eee74c56ece681507fdb1b2dea3f48e5102b1cda256bc138f06ddf6e1d765a193d9cbe146ceeb79ac1cb485ed5f5b37913a8cf5857eff00a98c97258f4e2489f1bb3d1029148e0d830b5a1399daff1084048e7bd8dbe9f859ac1ae3d087f29237062548f70c4c04aec2a995694986e7cbb467520621d38630b43ffa27f5d7f64a74c09b1f295879de4b09ab36dfc9dd514b321aa7b38ce5e8c6fa7af3bedbad3a3d65f36aabc97431b1bbe4c2d2f6e0e47ca60203452f5d6185f1796860bcb8df9d2010ebc55def1f0658b3646614a9bcec2d47b4eddef8d2070c000502c05c15000f060009002c0b0e01010b0200090c0200000080969800000000000e010901110f06000600120b0e01010d420e100009050a062c12070d110d2a2916190a051718102b0e0d270e2d2e10052122041f20260e1e251d1a1b281c1e1e1e1e1e1e040310230e101403150a130802012432c1209b3341d69c81050400000012003c000403280002076402031101640304809698000000000081a90900000000003200320e03090000010904078b5404952877ec5d2470a56806f07d8d0a72c3f24baa6ebe29f000a23b4b5703f5eeef061ef127367f5c150cabfd3ee71ef870b5d47eb9b845c5bb18c835bd6e65af5e3880f608e8a2a304c3bcbbbe03c0bfc26dfa655d0e72e2e4c32404088d28553d02f3f2ffa67bc53d8c977af083ca8cb905bcbd3cb8ba00ccda99cf882523cab2e63beba47628f15ce1e929aa460b396b41f6000385699c04eaece9e70365edeb")

        var signed = Data()
        signed.append(0x1)
        signed.append(Data(count: 64))
        signed.append(message)

        #expect(signed.base64EncodedString() == "AQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAQAIE4X7qT7inGBPqFijUWiMASkIQer7GcY6cKR108e8O++fF6bw89YHC7acs3m1YUIhVlGt8Lsh5HSIZozEPbcak9lEkZ+TiEMZdELfvcljcnBtv3Cf2z6oSYOBlVK0qYEJiVPvd6ryg3kqPlsEMcw3Fwx5sgoudurpYDKruhuxfayEdR478uf/smdZykpYhZIZWgIVX3IpDQW2WlWxw1AX3C53BHo4HDkVOPejukK6/oQdRT8m1S5xpmRD9q8e3XSK/Xu3TqNZNjLp6OSRg8r3sOv1e+QztSj31QG3tKRlT5zLqo0WQ1mJ0Hxkrw69L1dQmgMqgZd20xmPPvg53n23dsfNG6CPj/KUTsrekiJQc2Hvabji48RBleABXKq2lBKpj89u0FRUiC4li6CDgDgrZl6r6UV4hTXUW6fWb5yNguwg6dRIiwf+OZsakVXlghtpfUMBbAo8Tzu8oq+0HQFjMFcAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMGRm/lIRcy/+ytunLDm+e8jOW7xfcSayxDmzpAAAAABHnVW/IxwG7udMVuzmgVB/2xst6j9I5RArHNola8E48G3fbh12Whk9nL4UbO63msHLSF7V9bN5E6jPWFfv8AqYyXJY9OJInxuz0QKRSODYMLWhOZ2v8QhASOe9jb6fhZrBrj0IfykjcGJUj3DEwErsKplWlJhufLtGdSBiHThjC0P/on9df2SnTAmx8pWHneSwmrNt/J3VFLMhqns4zl6Mb6evO+2606PWXzaqvJdDGxu+TC0vbg5HymAgNFL11hhfF5aGC8uN+dIBDrxV3vHwZYs2RmFKm87C1HtO3e+NIHDAAFAsBcFQAPBgAJACwLDgEBCwIACQwCAAAAgJaYAAAAAAAOAQkBEQ8GAAYAEgsOAQENQg4QAAkFCgYsEgcNEQ0qKRYZCgUXGBArDg0nDi0uEAUhIgQfICYOHiUdGhsoHB4eHh4eHgQDECMOEBQDFQoTCAIBJDLBIJszQdacgQUEAAAAEgA8AAQDKAACB2QCAxEBZAMEgJaYAAAAAACBqQkAAAAAADIAMg4DCQAAAQkEB4tUBJUod+xdJHClaAbwfY0KcsPyS6puvinwAKI7S1cD9e7vBh7xJzZ/XBUMq/0+5x74cLXUfrm4RcW7GMg1vW5lr144gPYI6KKjBMO8u74DwL/CbfplXQ5y4uTDJAQIjShVPQLz8v+me8U9jJd68IPKjLkFvL08uLoAzNqZz4glI8qy5jvrpHYo8Vzh6SmqRgs5a0H2AAOFaZwE6uzp5wNl7es=")
    }

    @Test
    func testSignSolanaMessage() {
        let keyData = Base58.decodeNoCheck(string: "G282j1ejo5LbL4DqBR4G5i9EQZk1FPZa2ZR4VE9x6JaHqfie3nrrgcGL6UXLfXrappiPnWSWK5F1kz3Xduoy57H")!
        let key = PrivateKey(data: keyData[0..<32])!
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

