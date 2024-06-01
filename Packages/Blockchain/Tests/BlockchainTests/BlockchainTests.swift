import XCTest
@testable import Blockchain

final class BlockchainTests: XCTestCase {

    func testDeocdeString() throws {
        var hex = "0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000855534420436f696e000000000000000000000000000000000000000000000000"
        var result = EthereumService.decodeABI(hexString: hex)

        XCTAssertEqual(result, "USD Coin")

        hex = "0x0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000002c48656c6c6f20576f726c64212020202048656c6c6f20576f726c64212020202048656c6c6f20576f726c64210000000000000000000000000000000000000000"
        result = EthereumService.decodeABI(hexString: hex)
        XCTAssertEqual(result, "Hello World!    Hello World!    Hello World!")
    }

    func testDecodeSolanaAccount() throws {
        let json = """
        {
          "jsonrpc": "2.0",
          "result": {
            "context": {
              "apiVersion": "1.17.26",
              "slot": 260940224
            },
            "value": {
              "data": {
                "parsed": {
                  "info": {
                    "decimals": 6,
                    "freezeAuthority": null,
                    "isInitialized": true,
                    "mintAuthority": null,
                    "supply": "54879912097279332"
                  },
                  "type": "mint"
                },
                "program": "spl-token",
                "space": 82
              },
              "executable": false,
              "lamports": 346673537,
              "owner": "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
              "rentEpoch": 18446744073709551615,
              "space": 82
            }
          },
          "id": "1"
        }
        """

        let response = try JSONDecoder().decode(JSONRPCResponse<SolanaSplTokenInfo>.self, from: json.data(using: .utf8)!)
        let info = response.result.value.data.parsed.info

        XCTAssertEqual(info.decimals, 6)

        let json2 = """
        {
          "jsonrpc": "2.0",
          "result": {
            "context": {
              "apiVersion": "1.17.26",
              "slot": 260829184
            },
            "value": {
              "data": [
                "BDEpM9Ord5wKt0MA0ymbKmWB1PDhkGKl7XrsRv9HzYC+BS7hgziWlp+M0c1GgxjFmMfgWJYHSlkcKuCYYC8WgAAgAAAAY2F0IGluIGEgZG9ncyB3b3JsZAAAAAAAAAAAAAAAAAAKAAAATUVXAAAAAAAAAMgAAABodHRwczovL2JhZmtyZWlldW81YjdhYXZ2bTR1MmVhZmZ3aHpuNTNnN3Q0NWFjMjZpc292ZndsdXY2NTNsdmM1dTRpLmlwZnMubmZ0c3RvcmFnZS5saW5rLwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAf8BAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==",
                "base64"
              ],
              "executable": false,
              "lamports": 5616720,
              "owner": "metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s",
              "rentEpoch": 18446744073709551615,
              "space": 679
            }
          },
          "id": "bd8e71f2-2100-41a9-9458-dc438c7af5ff"
        }
        """

        let response2 = try JSONDecoder().decode(JSONRPCResponse<SolanaMplRawData>.self, from: json2.data(using: .utf8)!)

        XCTAssertTrue(response2.result.value.data.first!.count > 0)
    }
}
