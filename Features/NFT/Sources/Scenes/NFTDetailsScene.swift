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

    @State private var showPhotoPermissionMessage: Bool = false
    @State private var isPresentingErrorMessage: String?
    
    @State private var isPresentinSaveToPhotosToast = false
    @State private var isPresentingSetAsAvatarToast = false
    @Binding private var isPresentingCollectibleOptions: Bool
    
    let model: NFTDetailsViewModel
    
    public init(
        model: NFTDetailsViewModel,
        isPresentingCollectibleOptions: Binding<Bool>
    ) {
        self.model = model
        _isPresentingCollectibleOptions = isPresentingCollectibleOptions
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
                    .padding(.top, .medium)
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
                    onSelectSetAsAvatar()
                }
            }
            
            Section {
                ListItemView(
                    title: model.collectionTitle,
                    subtitle: model.collectionText
                )
                
                ListItemImageView(
                    title: model.networkTitle,
                    subtitle: model.networkText,
                    assetImage: model.networkAssetImage
                )
                
                if model.showContract {
                    ListItemView(title: model.contractTitle, subtitle: model.contractText)
                        .contextMenu {
                            ContextMenuCopy(value: model.contractValue)
                        }
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
            
            if model.showLinks {
                Section(Localized.Social.links) {
                    SocialLinksView(model: model.socialLinksViewModel)
                }
            }
        }
        .environment(\.defaultMinListHeaderHeight, 0)
        .listSectionSpacing(.compact)
        .navigationTitle(model.title)
        .background(Colors.grayBackground)
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
        .toast(
            isPresenting: $isPresentinSaveToPhotosToast,
            title: Localized.Nft.saveToPhotos,
            systemImage: SystemImage.checkmark
        )
        .toast(
            isPresenting: $isPresentingSetAsAvatarToast,
            title: Localized.Nft.setAsAvatar,
            systemImage: SystemImage.checkmark
        )
        .confirmationDialog("", isPresented: $isPresentingCollectibleOptions, titleVisibility: .hidden) {
            Button(Localized.Nft.saveToPhotos, action: onSelectSaveToGallery)
            Button(Localized.Nft.setAsAvatar, action: onSelectSetAsAvatar)
        }
    }
    
    private func onSelectSaveToGallery() {
        Task {
            do {
                try await model.saveImageToGallery()
                isPresentinSaveToPhotosToast = true
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
    
    private func onSelectSetAsAvatar() {
        Task {
            do {
                try await model.setWalletAvatar()
                isPresentingSetAsAvatarToast = true
            } catch {
                NSLog("Set nft avatar error: \(error)")
            }
        }
    }

    private func onSelectOpenSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(settingsURL)
    }
}
