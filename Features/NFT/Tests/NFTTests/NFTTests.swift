import Testing
import Foundation
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
    func contractText() {
        #expect(CollectibleViewModel.mock(assetData: .mock(
            collection: .mock(contractAddress: "0x123"),
            asset: .mock(tokenId: "456")
        )).contractText == "")
        #expect(CollectibleViewModel.mock(assetData: .mock(
            collection: .mock(contractAddress: "0x12345678910"),
            asset: .mock(tokenId: "")
        )).contractText == "0x12345678910")
        #expect(CollectibleViewModel.mock(assetData: .mock(
            collection: .mock(contractAddress: ""),
            asset: .mock(tokenId: "456")
        )).contractText == nil)
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
    
    @Test
    func onSelectViewTokenInExplorer() {
        let model = CollectibleViewModel.mock(assetData: .mock(asset: .mock(tokenId: "1234", chain: .ethereum)))
        
        #expect(model.isPresentingTokenExplorerUrl == nil)
        model.onSelectViewTokenInExplorer()
        #expect(model.isPresentingTokenExplorerUrl != nil)
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
