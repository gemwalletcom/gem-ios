// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import Style
import Components
import PrimitivesComponents
import Localization
import ImageGalleryService

public struct CollectibleScene: View {
    @Environment(\.openURL) private var openURL

    @State private var isPresentingPhotoPermissionMessage: Bool = false
    @State private var isPresentingErrorMessage: String?
    @State private var isPresentingSaveToPhotosToast = false
    @State private var isPresentingSetAsAvatarToast = false
    @Binding private var isPresentingCollectibleOptions: Bool?
    
    let model: CollectibleViewModel
    
    public init(
        model: CollectibleViewModel,
        isPresentingCollectibleOptions: Binding<Bool?>
    ) {
        self.model = model
        _isPresentingCollectibleOptions = isPresentingCollectibleOptions
    }
    
    public var body: some View {
        List {
            headerSectionView
            assetInfoSectionView
            if model.showAttributes {
                attributesSectionView
            }
            if model.showLinks {
                linksSectionView
            }
        }
        .environment(\.defaultMinListHeaderHeight, 0)
        .listSectionSpacing(.compact)
        .navigationTitle(model.title)
        .alert(Localized.Permissions.accessDenied, isPresented: $isPresentingPhotoPermissionMessage) {
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
            isPresenting: $isPresentingSaveToPhotosToast,
            title: Localized.Nft.saveToPhotos,
            systemImage: SystemImage.checkmark
        )
        .toast(
            isPresenting: $isPresentingSetAsAvatarToast,
            title: Localized.Nft.setAsAvatar,
            systemImage: SystemImage.checkmark
        )
        .confirmationDialog(model.title, presenting: $isPresentingCollectibleOptions) {_ in
            Button(Localized.Nft.saveToPhotos, action: onSelectSaveToGallery)
            Button(Localized.Nft.setAsAvatar, action: onSelectSetAsAvatar)
        }
    }
}

// MARK: - UI

extension CollectibleScene {
    private var headerSectionView: some View {
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
        .contextMenu([
            .custom(
                title: Localized.Nft.saveToPhotos,
                systemImage: SystemImage.gallery,
                action: onSelectSaveToGallery
            ),
            .custom(
                title: Localized.Nft.setAsAvatar,
                systemImage: SystemImage.emoji,
                action: onSelectSetAsAvatar
            )
        ])
    }
    
    private var assetInfoSectionView: some View {
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
                    .contextMenu(.copy(value: model.contractValue))
            }
            ListItemView(title: model.tokenIdTitle, subtitle: model.tokenIdText)
        }
    }
    
    private var attributesSectionView: some View {
        Section(model.attributesTitle) {
            ForEach(model.attributes) {
                ListItemView(title: $0.name, subtitle: $0.value)
            }
        }
    }
    
    private var linksSectionView: some View {
        Section(Localized.Social.links) {
            SocialLinksView(model: model.socialLinksViewModel)
        }
    }
}

// MARK: - Actions

extension CollectibleScene {
    private func onSelectSaveToGallery() {
        Task {
            do {
                try await model.saveImageToGallery()
                isPresentingSaveToPhotosToast = true
            } catch let error as ImageGalleryServiceError {
                switch error {
                case .wrongURL, .invalidData, .invalidResponse, .unexpectedStatusCode, .urlSessionError:
                    isPresentingErrorMessage = Localized.Errors.errorOccured
                case .permissionDenied:
                    isPresentingPhotoPermissionMessage = true
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
