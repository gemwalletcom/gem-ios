// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import Style
import Components

struct NFTDetailsScene: View {
    @Environment(\.dismiss) var dismiss

    let collection: NFTCollection
    let asset: NFTAsset
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                imageView
                
                Text(asset.name)
                    .textStyle(.headline)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                
                NftCollectionView(collection: collection)
                    .padding(.horizontal, 16)
                
                Button("View on Magic Eden", action: {})
                    .buttonStyle(.blue())
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                
                if let description = asset.description {
                    Text("Description")
                        .textStyle(.subheadline)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    
                    Text(description)
                        .textStyle(.body)
                        .padding(.horizontal, 16)
                }
                
                NFTAttributeView(attributes: asset.attributes, horizontalPadding: 16)
                    .padding(.top, 8)
                
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
            .padding(16)
            
            Spacer()
            
            NavigationButton(image: Image(systemName: "ellipsis")) {}
            .padding(16)
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
                        .frame(width: 44, height: 44)
                        .background(Colors.grayBackground)
                        .cornerRadius(22)
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
                    size: 24
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
