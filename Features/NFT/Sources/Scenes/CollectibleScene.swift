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
    @State private var model: CollectibleViewModel

    public init(model: CollectibleViewModel) {
        _model = State(initialValue: model)
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
        .alertSheet($model.isPresentingAlertMessage)
        .toast(message: $model.isPresentingToast)
        .safariSheet(url: $model.isPresentingTokenExplorerUrl)
        .sheet(isPresented: $model.isPresentingReportSheet) {
            ReportNavigationStack(
                model: ReportNftViewModel(
                    nftService: model.nftService,
                    assetData: model.assetData,
                    onComplete: model.onReportComplete
                )
            )
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
            HeaderButtonsView(buttons: model.headerButtons, action: model.onSelectHeaderButton(type:))
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
                action: model.onSelectSaveToGallery
            ),
            .custom(
                title: Localized.Nft.setAsAvatar,
                systemImage: SystemImage.emoji,
                action: model.onSelectSetAsAvatar
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

            if let text = model.contractText {
                ListItemView(title: model.contractTitle, subtitle: text)
                    .contextMenu(model.contractContextMenu)
            }
            ListItemView(title: model.tokenIdTitle, subtitle: model.tokenIdText)
                .contextMenu(model.tokenIdContextMenu)
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

