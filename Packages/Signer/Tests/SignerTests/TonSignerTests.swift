// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import PrimitivesTestKit
@testable import Signer
import Testing
import WalletCore
import WalletCorePrimitives
import BigInt

struct TonSignerTests {
    
    let asset = Asset(.ton).chain.asset
    let signer = TonSigner()
    
//    @Test
//    func regularTransfer() throws {
//        
//        let input = SignerInput.mock(
//            type: .transfer(asset),
//            asset: asset,
//            value: BigInt(1000000000),
//            isMaxAmount: false,
//            senderAddress: "EQB3ncyBUTjZUA5EnFKR5_EnOMI9V1tTEAAPaiU71gc4TiUt",
//            destinationAddress: "EQB3ncyBUTjZUA5EnFKR5_EnOMI9V1tTEAAPaiU71gc4TiUt",
//            metadata: .ton(senderTokenAddress: .none, recipientTokenAddress: .none, sequence: 1)
//        )
//        
//        let result = try signer.signTransfer(input: input, privateKey: TestPrivateKey)
//        
//        #expect(result == "te6cckECGgEAA7UAAkWIAfwnpmM1phMM8iLsWlpdDP6ZWmNey1GIfMGzTrcYmg3OHgECAgE0AwQBnKx7ZYWHOnRWg8jFZ33i4C0MXrBpjwCgURSBFOzL4GdFfSId51wZ1aStVljrWKPTPHk1lEdVuvYQNZLbyxuLcgEpqaMX/////wAAAAAAAwUBFP8A9KQT9LzyyAsGAFEAAAAAKamjF9NpRSGXwqVkgeXi0+i/A94jSfZ6YxUZVoIiCMIzSt7iQAFoQgA7zuZAqJxsqAciTilI8/iTnGEeq62piAAHtRKd6wOcJyHc1lAAAAAAAAAAAAAAAAAAAQcCASAICQAAAgFICgsE+PKDCNcYINMf0x/THwL4I7vyZO1E0NMf0x/T//QE0VFDuvKhUVG68qIF+QFUEGT5EPKj+AAkpMjLH1JAyx9SMMv/UhD0AMntVPgPAdMHIcAAn2xRkyDXSpbTB9QC+wDoMOAhwAHjACHAAuMAAcADkTDjDQOkyMsfEssfy/8MDQ4PAubQAdDTAyFxsJJfBOAi10nBIJJfBOAC0x8hghBwbHVnvSKCEGRzdHK9sJJfBeAD+kAwIPpEAcjKB8v/ydDtRNCBAUDXIfQEMFyBAQj0Cm+hMbOSXwfgBdM/yCWCEHBsdWe6kjgw4w0DghBkc3RyupJfBuMNEBECASASEwBu0gf6ANTUIvkABcjKBxXL/8nQd3SAGMjLBcsCIs8WUAX6AhTLaxLMzMlz+wDIQBSBAQj0UfKnAgBwgQEI1xj6ANM/yFQgR4EBCPRR8qeCEG5vdGVwdIAYyMsFywJQBs8WUAT6AhTLahLLH8s/yXP7AAIAbIEBCNcY+gDTPzBSJIEBCPRZ8qeCEGRzdHJwdIAYyMsFywJQBc8WUAP6AhPLassfEss/yXP7AAAK9ADJ7VQAeAH6APQEMPgnbyIwUAqhIb7y4FCCEHBsdWeDHrFwgBhQBMsFJs8WWPoCGfQAy2kXyx9SYMs/IMmAQPsABgCKUASBAQj0WTDtRNCBAUDXIMgBzxb0AMntVAFysI4jghBkc3Rygx6xcIAYUAXLBVADzxYj+gITy2rLH8s/yYBA+wCSXwPiAgEgFBUAWb0kK29qJoQICga5D6AhhHDUCAhHpJN9KZEM5pA+n/mDeBKAG3gQFImHFZ8xhAIBWBYXABG4yX7UTQ1wsfgAPbKd+1E0IEBQNch9AQwAsjKB8v/ydABgQEI9ApvoTGACASAYGQAZrc52omhAIGuQ64X/wAAZrx32omhAEGuQ64WPwKL3N4Q=")
//    }
//    
//    @Test
//    func maxAmountTransfer() throws {
//        let input = SignerInput.mock(
//            type: .transfer(asset),
//            asset: asset,
//            value: BigInt(1000000000),
//            isMaxAmount: true,
//            senderAddress: "EQB3ncyBUTjZUA5EnFKR5_EnOMI9V1tTEAAPaiU71gc4TiUt",
//            destinationAddress: "EQB3ncyBUTjZUA5EnFKR5_EnOMI9V1tTEAAPaiU71gc4TiUt",
//            metadata: .ton(senderTokenAddress: .none, recipientTokenAddress: .none, sequence: 1)
//        )
//        
//        let result = try signer.signTransfer(input: input, privateKey: TestPrivateKey)
//        
//        #expect(result == "te6cckECGgEAA7UAAkWIAfwnpmM1phMM8iLsWlpdDP6ZWmNey1GIfMGzTrcYmg3OHgECAgE0AwQBnJYWxx5gib8sXnAtPzPZUIBwS7PbhA442QYOiSyBQemtznMcpV+h+VtZy1Q7FBv+eKU98hWbgVenAhCf7aBaUQEpqaMX/////wAAAAAAgwUBFP8A9KQT9LzyyAsGAFEAAAAAKamjF9NpRSGXwqVkgeXi0+i/A94jSfZ6YxUZVoIiCMIzSt7iQAFoQgA7zuZAqJxsqAciTilI8/iTnGEeq62piAAHtRKd6wOcJyHc1lAAAAAAAAAAAAAAAAAAAQcCASAICQAAAgFICgsE+PKDCNcYINMf0x/THwL4I7vyZO1E0NMf0x/T//QE0VFDuvKhUVG68qIF+QFUEGT5EPKj+AAkpMjLH1JAyx9SMMv/UhD0AMntVPgPAdMHIcAAn2xRkyDXSpbTB9QC+wDoMOAhwAHjACHAAuMAAcADkTDjDQOkyMsfEssfy/8MDQ4PAubQAdDTAyFxsJJfBOAi10nBIJJfBOAC0x8hghBwbHVnvSKCEGRzdHK9sJJfBeAD+kAwIPpEAcjKB8v/ydDtRNCBAUDXIfQEMFyBAQj0Cm+hMbOSXwfgBdM/yCWCEHBsdWe6kjgw4w0DghBkc3RyupJfBuMNEBECASASEwBu0gf6ANTUIvkABcjKBxXL/8nQd3SAGMjLBcsCIs8WUAX6AhTLaxLMzMlz+wDIQBSBAQj0UfKnAgBwgQEI1xj6ANM/yFQgR4EBCPRR8qeCEG5vdGVwdIAYyMsFywJQBs8WUAT6AhTLahLLH8s/yXP7AAIAbIEBCNcY+gDTPzBSJIEBCPRZ8qeCEGRzdHJwdIAYyMsFywJQBc8WUAP6AhPLassfEss/yXP7AAAK9ADJ7VQAeAH6APQEMPgnbyIwUAqhIb7y4FCCEHBsdWeDHrFwgBhQBMsFJs8WWPoCGfQAy2kXyx9SYMs/IMmAQPsABgCKUASBAQj0WTDtRNCBAUDXIMgBzxb0AMntVAFysI4jghBkc3Rygx6xcIAYUAXLBVADzxYj+gITy2rLH8s/yYBA+wCSXwPiAgEgFBUAWb0kK29qJoQICga5D6AhhHDUCAhHpJN9KZEM5pA+n/mDeBKAG3gQFImHFZ8xhAIBWBYXABG4yX7UTQ1wsfgAPbKd+1E0IEBQNch9AQwAsjKB8v/ydABgQEI9ApvoTGACASAYGQAZrc52omhAIGuQ64X/wAAZrx32omhAEGuQ64WPwPdIlEI=")
//    }
}
