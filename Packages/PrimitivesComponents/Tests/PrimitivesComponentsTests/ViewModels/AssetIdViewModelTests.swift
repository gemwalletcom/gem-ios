// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import PrimitivesComponents
import Primitives
import PrimitivesTestKit
import Components

struct AssetIdViewModelTests {
    
    @Test
    func networkAssetImage() {
        #expect(
            AssetIdViewModel(assetId: .mock(.bitcoin)).networkAssetImage == AssetImage(
                type: .empty,
                placeholder: ChainImage(chain: .bitcoin).image
            )
        )
        #expect(
            AssetIdViewModel(assetId: .mock(.ethereum)).networkAssetImage == AssetImage(
                type: .empty,
                placeholder: ChainImage(chain: .ethereum).image
            )
        )
        #expect(
            AssetIdViewModel(assetId: .mock(.arbitrum)).networkAssetImage == AssetImage(
                type: .empty,
                placeholder: ChainImage(chain: .arbitrum).l2Image
            )
        )
    }
    
    @Test
    func assetImage() {
        #expect(
            AssetIdViewModel(assetId: .mock(.bitcoin)).assetImage == AssetImage(
                type: .empty,
                placeholder: ChainImage(chain: .bitcoin).image
            )
        )
        #expect(
            AssetIdViewModel(assetId: .mock(.ethereum)).assetImage == AssetImage(
                type: "ERC20",
                placeholder: ChainImage(chain: .ethereum).image
            )
        )
        #expect(
            AssetIdViewModel(assetId: .mock(.arbitrum)).assetImage == AssetImage(
                type: "ERC20",
                placeholder: ChainImage(chain: .arbitrum).image,
                chainPlaceholder: ChainImage(chain: .arbitrum).l2Image
            )
        )
    }
    
    @Test
    func assetImageHyperCorePerpetual() {
        let btcPerpetualAssetId = AssetId(chain: .hyperCore, tokenId: "perpetual::BTC")
        let btcImage = AssetIdViewModel(assetId: .mock(.bitcoin)).assetImage
        let btcPerpetualImage = AssetIdViewModel(assetId: btcPerpetualAssetId).assetImage
        
        #expect(btcPerpetualImage.type == "PERPETUAL")
        #expect(btcPerpetualImage.placeholder == btcImage.placeholder)
        #expect(btcPerpetualImage.chainPlaceholder == ChainImage(chain: .hyperCore).placeholder)
        
        let ethPerpetualAssetId = AssetId(chain: .hyperCore, tokenId: "perpetual::ETH")
        let ethImage = AssetIdViewModel(assetId: .mock(.ethereum)).assetImage  
        let ethPerpetualImage = AssetIdViewModel(assetId: ethPerpetualAssetId).assetImage
        
        #expect(ethPerpetualImage.type == "PERPETUAL")
        #expect(ethPerpetualImage.placeholder == ethImage.placeholder)
        #expect(ethPerpetualImage.chainPlaceholder == ChainImage(chain: .hyperCore).placeholder)
    }
}
