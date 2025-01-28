// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesComponents
import Localization
import Components
import Style

public struct NFTDetailsViewModel {
    public let assetData: NFTAssetData
    private let headerButtonAction: HeaderButtonAction?
    
    public init(
        assetData: NFTAssetData,
        headerButtonAction: HeaderButtonAction?
    ) {
        self.assetData = assetData
        self.headerButtonAction = headerButtonAction
    }
    
    public var title: String {
        assetData.asset.name
    }
    
    public var description: String? {
        assetData.asset.description
    }
    
    public var collectionTitle: String {
        Localized.Nft.collection
    }
    
    public var collectionText: String {
        assetData.collection.name
    }
    
    public var collectionAssetImage: AssetImage {
        AssetImage(
            imageURL: URL(string: assetData.collection.image.previewImageUrl),
            placeholder: .none,
            chainPlaceholder: .none
        )
    }
    
    public var networkTitle: String {
        Localized.Transfer.network
    }
    
    public var networkText: String {
        assetData.asset.chain.asset.name
    }
    
    public var contractTitle: String {
        Localized.Asset.contract
    }
    
    public var networkAssetImage: AssetImage {
        AssetImage(
            imageURL: .none,
            placeholder: ChainImage(chain: assetData.asset.chain).image,
            chainPlaceholder: .none
        )
    }

    public var contractText: String {
        AddressFormatter(address: contractValue, chain: assetData.asset.chain).value()
    }
    
    public var contractValue: String {
        assetData.collection.contractAddress
    }
    
    public var tokenIdTitle: String {
        Localized.Asset.tokenId
    }
    
    public var tokenIdText: String {
        "#\(assetData.asset.tokenId)"
    }
    
    public var attributesTitle: String {
        Localized.Nft.properties
    }
    
    public var attributes: [NFTAttribute] {
        assetData.asset.attributes
    }
    
    public var assetImage: AssetImage {
        NFTAssetViewModel(asset: assetData.asset).assetImage
    }
    
    public var headerButtons: [HeaderButton] {
        [
            HeaderButton(type: .send, isEnabled: true),
            HeaderButton(type: .more, isEnabled: true),
        ]
    }
    
    func onHeaderAction(type: HeaderButtonType) {
        headerButtonAction?(type)
    }
}
