// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import Style
import Components
import PrimitivesComponents
import Localization
import ImageGalleryService

public struct NFTDetailsScene: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) private var openURL

    @State private var showSavedMessage: Bool = false
    @State private var showPhotoPermissionMessage: Bool = false
    @State private var isPresentingErrorMessage: String?

    let model: NFTDetailsViewModel
    
    public init(model: NFTDetailsViewModel) {
        self.model = model
    }
    
    public var body: some View {
        List {
            Section {
                NftImageView(assetImage: model.assetImage)
                    .aspectRatio(1, contentMode: .fill)
            } header: {
                Spacer()
            } footer: {
				HeaderButtonsView(buttons: model.headerButtons, action: model.onHeaderAction)
					.padding(.top, Spacing.small)
            }
            .frame(maxWidth: .infinity)
            .textCase(nil)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
            .contextMenu {
                ContextMenuItem(
                    title: Localized.Nft.saveToPhotos,
                    image: SystemImage.gallery
                ) {
                    saveImageToGallery()
                }
            }
            
            Section {
                ListItemImageView(
                    title: model.collectionTitle,
                    subtitle: model.collectionText,
                    assetImage: model.collectionAssetImage
                )
                
                ListItemImageView(
                    title: model.networkTitle,
                    subtitle: model.networkText,
                    assetImage: model.networkAssetImage
                )
                
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
        .environment(\.defaultMinListHeaderHeight, 0)
        .listSectionSpacing(.compact)
        .navigationTitle(model.title)
        .background(Colors.grayBackground)
        .modifier(
            ToastModifier(
                isPresenting: $showSavedMessage,
                value: Localized.Nft.successSavedToPhotos,
                systemImage: SystemImage.gallery
            )
        )
        .alert(Localized.Permissions.accessDenied, isPresented: $showPhotoPermissionMessage) {
            Button(Localized.Common.openSettings) {
                onSelectOpenSettings()
            }
            Button(Localized.Common.cancel, role: .cancel) {}
        } message: {
            Text(Localized.Permissions.Image.PhotoAccess.Denied.description)
        }
        .alert("",
            isPresented: $isPresentingErrorMessage.mappedToBool(),
            actions: {},
            message: {
                Text(isPresentingErrorMessage ?? "")
            }
        )
    }

    private func saveImageToGallery() {
        Task {
            do {
                try await model.saveImageToGallery()
                showSavedMessage = true
            } catch let error as ImageGalleryServiceError {
                switch error {
                case .wrongURL, .invalidData, .invalidResponse, .unexpectedStatusCode, .urlSessionError:
                    isPresentingErrorMessage = Localized.Errors.errorOccured
                case .permissionDenied:
                    showPhotoPermissionMessage = true
                }
            }
        }
    }

    private func onSelectOpenSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(settingsURL)
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
