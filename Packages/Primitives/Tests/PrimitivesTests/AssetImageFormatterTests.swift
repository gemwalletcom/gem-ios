// Copyright (c). Gem Wallet. All rights reserved.

import Testing
@testable import Primitives

final class AssetImageFormatterTests {
    
    @Test
    func getURL() {
        let formatter = AssetImageFormatter()
        
        #expect(formatter.getURL(for: AssetId(chain: .ethereum, tokenId: .none)).absoluteString == "\(Constants.assetsURL)/blockchains/ethereum/logo.png")
        #expect(formatter.getURL(for: AssetId(chain: .ethereum, tokenId: "0xdAC17F958D2ee523a2206206994597C13D831ec7")).absoluteString == "\(Constants.assetsURL)/blockchains/ethereum/assets/0xdAC17F958D2ee523a2206206994597C13D831ec7/logo.png")
    }
    
    @Test
    func getNFTUrl() {
        let formatter = AssetImageFormatter()
        
        #expect(
            formatter
                .getNFTUrl(
                    for: "test-asset-id"
                ).absoluteString == "\(Constants.apiURL.absoluteString)/v1/nft/assets/test-asset-id/image_preview"
        )
    }
    
    @Test
    func getValidatorUrl() {
        let formatter = AssetImageFormatter()
        
        #expect(formatter.getValidatorUrl(chain: .ethereum, id: "validator1").absoluteString == "\(Constants.assetsURL)/blockchains/ethereum/validators/validator1/logo.png")
    }
}
