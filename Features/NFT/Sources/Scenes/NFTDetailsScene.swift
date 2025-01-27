// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import Style
import Components
import PrimitivesComponents

public struct NFTDetailsScene: View {
    @Environment(\.dismiss) var dismiss

    let model: NFTDetailsViewModel
    
    public init(model: NFTDetailsViewModel) {
        self.model = model
    }
    
    public var body: some View {
        List {
            Section { } header: {
                VStack {
                    NftImageView(assetImage: model.assetImage)
                        .cornerRadius(Spacing.medium)
                        .aspectRatio(1, contentMode: .fill)
                    
                    Spacer()
                    
//                    HeaderButtonsView(buttons: model.headerButtons, action: model.onHeaderAction)
//                    .padding(.top, Spacing.small)
                }
            }
            .frame(maxWidth: .infinity)
            .textCase(nil)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
            
            
            
            Section {
                ListItemView(title: model.collectionTitle, subtitle: model.collectionText)
                HStack {
                    ListItemView(title: model.networkTitle, subtitle: model.networkText)
                    AssetImageView(assetImage: model.networkAssetImage, size: Sizing.list.image)
                }
                
                ListItemView(title: model.contractTitle, subtitle: model.contractText)
                    .contextMenu {
                        ContextMenuCopy(value: model.contractValue)
                    }
                ListItemView(title: model.tokenIdTitle, subtitle: model.tokenIdText)
            }
            
            if !model.attributes.isEmpty {
                Section(model.attributesTitle) {
                    ForEach(model.attributes) {
                        ListItemView(title: $0.name, subtitle: $0.value)
                    }
                }
            }
        }
        .listSectionSpacing(.compact)
        .navigationTitle(model.title)
        .background(Colors.grayBackground)
    }
}

//#Preview {
//    NFTDetailsScene(
//        collection: NFTCollection(
//            id: "",
//            name: "Alien Frens Evolution",
//            description: "[**ALIEN FRENS WEBSITE**](https://alienfrens.io) **|** [**ALIEN FRENS TWITTER**](https://TWITTER.COM/ALIENFRENS)\r\n\r\nalien frens... Evolved\r\n\r\nincubators - https://incubator.alienfrens.io",
//            chain: .ethereum,
//            contractAddress: "",
//            image: NFTImage(
//                imageUrl: "https://metadata.nftscan.com/eth/0x47a00fc8590c11be4c419d9ae50dec267b6e24ee/0x0000000000000000000000000000000000000000000000000000000000002e5f.png",
//                previewImageUrl: "https://metadata.nftscan.com/eth/0x47a00fc8590c11be4c419d9ae50dec267b6e24ee/0x0000000000000000000000000000000000000000000000000000000000002e5f.png",
//                originalSourceUrl: "https://metadata.nftscan.com/eth/0x47a00fc8590c11be4c419d9ae50dec267b6e24ee/0x0000000000000000000000000000000000000000000000000000000000002e5f.png"
//            ),
//            isVerified: true
//        ),
//        asset: NFTAsset(
//            id: "id",
//            collectionId: "collection id",
//            tokenId: "token id",
//            tokenType: .erc1155,
//            name: "Alien Frens Evolution #11871",
//            description: "Alien Frens have evolved! We’re creating new Frens and partnerships along the way. Learn more at alienfrens.io/incubationchamber",
//            chain: .ethereum,
//            image: NFTImage(
//                imageUrl: "https://metadata.nftscan.com/eth/0x47a00fc8590c11be4c419d9ae50dec267b6e24ee/0x0000000000000000000000000000000000000000000000000000000000002e5f.png",
//                previewImageUrl: "https://metadata.nftscan.com/eth/0x47a00fc8590c11be4c419d9ae50dec267b6e24ee/0x0000000000000000000000000000000000000000000000000000000000002e5f.png",
//                originalSourceUrl: "https://metadata.nftscan.com/eth/0x47a00fc8590c11be4c419d9ae50dec267b6e24ee/0x0000000000000000000000000000000000000000000000000000000000002e5f.png"
//            ),
//            attributes: [
//                .init(name: "Background", value: "Deep Space"),
//                .init(name: "Body", value: "Blue"),
//                .init(name: "Clothes", value: "Yellow Fuzzy Sweater"),
//                .init(name: "Eyes", value: "Baby Toon"),
//                .init(name: "Hats ", value: "Red Bucket Hat"),
//                .init(name: "Mouth", value: "Stoked")
//            ]
//        )
//    )
//}
