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
        #expect(CollectibleViewModel.mock(assetData: .mock(asset: .mock(tokenId: "12345"))).tokenIdValue == "12345")
    }
    
    @Test
    func tokenIdText() {
        let shortModel = CollectibleViewModel.mock(assetData: .mock(asset: .mock(tokenId: "123")))
        let longModel = CollectibleViewModel.mock(assetData: .mock(asset: .mock(tokenId: "1234567890123456789")))
        
        #expect(shortModel.tokenIdText == "#123")
        #expect(longModel.tokenIdText == "1234567890123456789")
    }
    
    @Test
    func showContract() {
        #expect(CollectibleViewModel.mock(assetData: .mock(
            collection: .mock(contractAddress: "0x123"),
            asset: .mock(tokenId: "456")
        )).showContract == true)
        #expect(CollectibleViewModel.mock(assetData: .mock(
            collection: .mock(contractAddress: "0x123"),
            asset: .mock(tokenId: "0x123")
        )).showContract == false)
    }
    
    @Test
    func tokenExplorerUrl() {
        #expect(CollectibleViewModel.mock(assetData: .mock(asset: .mock(tokenId: "1234", chain: .ethereum))).tokenExplorerUrl != nil)
    }
    
    @Test
    func showAttributes() {
        #expect(CollectibleViewModel.mock(assetData: .mock(asset: .mock(attributes: []))).showAttributes == false)
        
        let withAttributesModel = CollectibleViewModel.mock(assetData: .mock(asset: .mock(attributes: [
            NFTAttribute(name: "Color", value: "Blue", percentage: nil)
        ])))
        #expect(withAttributesModel.showAttributes == true)
    }
    
    @Test
    func showLinks() {
        #expect(CollectibleViewModel.mock(assetData: .mock(collection: .mock(links: []))).showLinks == false)
        #expect(CollectibleViewModel.mock(assetData: .mock(collection: .mock(links: [
            AssetLink(name: "Website", url: "https://example.com")
        ]))).showLinks == true)
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
