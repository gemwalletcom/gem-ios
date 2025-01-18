// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import Style
import Components
import Localization

public struct NFTDetailsScene: View {
    @Environment(\.dismiss) var dismiss

    let collection: NFTCollection
    let asset: NFTAsset
    
    public init(collection: NFTCollection, asset: NFTAsset) {
        self.collection = collection
        self.asset = asset
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                imageView
                
                Text(asset.name)
                    .textStyle(.headline)
                    .padding(.horizontal, Spacing.medium)
                    .padding(.top, Spacing.small)
                
                NftCollectionView(collection: collection)
                    .padding(.horizontal, Spacing.medium)
                
                Button(Localized.Transaction.viewOn("Magic Eden"), action: {})
                    .buttonStyle(.blue())
                    .padding(.horizontal, Spacing.medium)
                    .padding(.top, Spacing.small)
                
                if let description = asset.description {
                    Text(Localized.Nft.description)
                        .textStyle(.subheadline)
                        .padding(.horizontal, Spacing.medium)
                        .padding(.top, Spacing.small)
                    
                    Text(description)
                        .textStyle(.body)
                        .padding(.horizontal, Spacing.medium)
                }
                
                NFTAttributeView(attributes: asset.attributes)
                    .padding(.horizontal, Spacing.medium)
                    .padding(.top, Spacing.small)
                
                Spacer()
            }
        }
        .overlay(content: {
            VStack {
                navigationButtonView
                Spacer()
            }
        })
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
        .background(Colors.grayBackground)
    }
    
    private var imageView: some View {
        CachedAsyncImage(
            url: URL(string: asset.image.imageUrl),
            scale: UIScreen.main.scale
        ) {
            $0.resizable()
        } placeholder: {
            ZStack {
                Rectangle()
                    .foregroundStyle(Colors.white)
                LoadingView()
            }
        }
        .aspectRatio(1, contentMode: .fill)
    }
    
    private var navigationButtonView: some View {
        HStack {
            NavigationButton(image: Image(systemName: "chevron.left")) {
                dismiss()
            }
            .padding(Spacing.medium)
            
            Spacer()
            
            NavigationButton(image: Image(systemName: "ellipsis")) {}
            .padding(Spacing.medium)
        }
        .padding(.top, 60)
    }
    
    private struct NavigationButton: View {
        let image: Image
        let action: (() -> Void)?
        
        var body: some View {
            Button {
                action?()
            } label: {
                VStack(alignment: .center) {
                    image
                        .frame(width: Sizing.image.medium, height: Sizing.image.medium)
                        .background(Colors.grayBackground)
                        .cornerRadius(Sizing.image.medium / 2)
                }
            }
            .buttonStyle(.borderless)
        }
    }
    
    private struct NftCollectionView: View {
        let collection: NFTCollection
        
        var body: some View {
            HStack(spacing: 8) {
                AssetImageView(
                    assetImage: AssetImage(
                        imageURL: URL(string: collection.image.previewImageUrl),
                        placeholder: nil,
                        chainPlaceholder: nil
                    ),
                    size: Sizing.list.image
                )
                Text(collection.name)
                    .textStyle(.subheadline)
                Image(systemName: "arrow.right")
            }
        }
    }
}

#Preview {
    NFTDetailsScene(
        collection: NFTCollection(
            id: "",
            name: "Alien Frens Evolution",
            description: "[**ALIEN FRENS WEBSITE**](https://alienfrens.io) **|** [**ALIEN FRENS TWITTER**](https://TWITTER.COM/ALIENFRENS)\r\n\r\nalien frens... Evolved\r\n\r\nincubators - https://incubator.alienfrens.io",
            chain: .ethereum,
            contractAddress: "",
            image: NFTImage(
                imageUrl: "https://metadata.nftscan.com/eth/0x47a00fc8590c11be4c419d9ae50dec267b6e24ee/0x0000000000000000000000000000000000000000000000000000000000002e5f.png",
                previewImageUrl: "https://metadata.nftscan.com/eth/0x47a00fc8590c11be4c419d9ae50dec267b6e24ee/0x0000000000000000000000000000000000000000000000000000000000002e5f.png",
                originalSourceUrl: "https://metadata.nftscan.com/eth/0x47a00fc8590c11be4c419d9ae50dec267b6e24ee/0x0000000000000000000000000000000000000000000000000000000000002e5f.png"
            ),
            isVerified: true
        ),
        asset: NFTAsset(
            id: "id",
            collectionId: "collection id",
            tokenId: "token id",
            tokenType: .erc1155,
            name: "Alien Frens Evolution #11871",
            description: "Alien Frens have evolved! We’re creating new Frens and partnerships along the way. Learn more at alienfrens.io/incubationchamber",
            chain: .ethereum,
            image: NFTImage(
                imageUrl: "https://metadata.nftscan.com/eth/0x47a00fc8590c11be4c419d9ae50dec267b6e24ee/0x0000000000000000000000000000000000000000000000000000000000002e5f.png",
                previewImageUrl: "https://metadata.nftscan.com/eth/0x47a00fc8590c11be4c419d9ae50dec267b6e24ee/0x0000000000000000000000000000000000000000000000000000000000002e5f.png",
                originalSourceUrl: "https://metadata.nftscan.com/eth/0x47a00fc8590c11be4c419d9ae50dec267b6e24ee/0x0000000000000000000000000000000000000000000000000000000000002e5f.png"
            ),
            attributes: [
                .init(name: "Background", value: "Deep Space"),
                .init(name: "Body", value: "Blue"),
                .init(name: "Clothes", value: "Yellow Fuzzy Sweater"),
                .init(name: "Eyes", value: "Baby Toon"),
                .init(name: "Hats ", value: "Red Bucket Hat"),
                .init(name: "Mouth", value: "Stoked")
            ]
        )
    )
}
