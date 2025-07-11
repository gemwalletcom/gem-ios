import Testing
import Primitives
import PrimitivesTestKit
import WalletServiceTestKit
import StoreTestKit
import ExplorerService
import PrimitivesComponents
import AvatarService
import Store

@testable import NFT

@MainActor
struct CollectibleViewModelTests {
    
    @Test
    func tokenIdValue() {
        let assetData = NFTAssetData.mock(
            asset: .mock(tokenId: "12345")
        )
        let model = CollectibleViewModel.mock(assetData: assetData)
        
        #expect(model.tokenIdValue == "12345")
    }
    
    @Test
    func tokenIdText() {
        let shortTokenId = NFTAssetData.mock(
            asset: .mock(tokenId: "123")
        )
        let longTokenId = NFTAssetData.mock(
            asset: .mock(tokenId: "1234567890123456789")
        )
        
        let shortModel = CollectibleViewModel.mock(assetData: shortTokenId)
        let longModel = CollectibleViewModel.mock(assetData: longTokenId)
        
        #expect(shortModel.tokenIdText == "#123")
        #expect(longModel.tokenIdText == "1234567890123456789")
    }
    
    @Test
    func showContract() {
        let differentAddresses = NFTAssetData.mock(
            collection: .mock(contractAddress: "0x123"),
            asset: .mock(tokenId: "456")
        )
        let sameAddresses = NFTAssetData.mock(
            collection: .mock(contractAddress: "0x123"),
            asset: .mock(tokenId: "0x123")
        )
        
        let differentModel = CollectibleViewModel.mock(assetData: differentAddresses)
        let sameModel = CollectibleViewModel.mock(assetData: sameAddresses)
        
        #expect(differentModel.showContract == true)
        #expect(sameModel.showContract == false)
    }
    
    @Test
    func tokenExplorerUrl() {
        let assetData = NFTAssetData.mock(
            asset: .mock(
                tokenId: "1234",
                chain: .ethereum
            )
        )
        let model = CollectibleViewModel.mock(assetData: assetData)
        
        #expect(model.tokenExplorerUrl != nil)
    }
    
    @Test
    func showAttributes() {
        let emptyAttributes = NFTAssetData.mock(
            asset: .mock(attributes: [])
        )
        let withAttributes = NFTAssetData.mock(
            asset: .mock(attributes: [
                NFTAttribute(name: "Color", value: "Blue", percentage: nil)
            ])
        )
        
        let emptyModel = CollectibleViewModel.mock(assetData: emptyAttributes)
        let withModel = CollectibleViewModel.mock(assetData: withAttributes)
        
        #expect(emptyModel.showAttributes == false)
        #expect(withModel.showAttributes == true)
    }
    
    @Test
    func showLinks() {
        let emptyLinks = NFTAssetData.mock(
            collection: .mock(links: [])
        )
        let withLinks = NFTAssetData.mock(
            collection: .mock(links: [
                AssetLink(name: "Website", url: "https://example.com")
            ])
        )
        
        let emptyModel = CollectibleViewModel.mock(assetData: emptyLinks)
        let withModel = CollectibleViewModel.mock(assetData: withLinks)
        
        #expect(emptyModel.showLinks == false)
        #expect(withModel.showLinks == true)
    }
}

// MARK: - Mock Extensions

extension CollectibleViewModel {
    static func mock(
        wallet: Wallet = .mock(),
        assetData: NFTAssetData = .mock(),
        explorerService: ExplorerService = ExplorerService.standard,
        headerButtonAction: HeaderButtonAction? = nil
    ) -> CollectibleViewModel {
        CollectibleViewModel(
            wallet: wallet,
            assetData: assetData,
            avatarService: AvatarService(store: WalletStore.mock()),
            explorerService: explorerService,
            headerButtonAction: headerButtonAction
        )
    }
}
