// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import Primitives
@testable import Blockchain

final class SolanaServiceTests {

    @Test()
    func testDecodeSolanaAccount() throws {
        guard let accountURL = Bundle.module.url(forResource: "SolanaAccountMPLRawData", withExtension: "json") else {
            throw AnyError("Cannot access SolanaAccountMPLRawData.json")
        }
        let accountData = try Data(contentsOf: accountURL)
        let response = try JSONDecoder().decode(JSONRPCResponse<SolanaSplTokenInfo>.self, from: accountData)
        let info = response.result.value.data.parsed.info
        
        #expect(info.decimals == 6)

        guard let rawDataURL = Bundle.module.url(forResource: "SolanaAccountSPLTokenInfo", withExtension: "json") else {
            throw AnyError("Cannot access SolanaAccountSPLTokenInfo.json")
        }
        let rawDataData = try Data(contentsOf: rawDataURL)
        let response2 = try JSONDecoder().decode(JSONRPCResponse<SolanaMplRawData>.self, from: rawDataData)

        #expect(response2.result.value.data.first!.count > 0)
    }
}
