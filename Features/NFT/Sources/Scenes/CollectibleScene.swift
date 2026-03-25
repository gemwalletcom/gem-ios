// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import SwiftUI
import Style
import Components
import PrimitivesComponents
import Localization
import InfoSheet

public struct CollectibleScene: View {
    @State private var model: CollectibleViewModel

    public init(model: CollectibleViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        List {
            headerSectionView
            if model.showStatus {
                statusSectionView
            }
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
        .contentMargins([.top], .small, for: .scrollContent)
        .navigationTitle(model.title)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: .tiny) {
                    Text(model.title)
                        .font(.headline)
                    if model.isVerified {
                        VerifiedBadgeView()
                    }
                }
            }
        }
        .alertSheet($model.isPresentingAlertMessage)
        .toast(message: $model.isPresentingToast)
        .sheet(isPresented: $model.isPresentingReportSheet) {
            ReportNavigationStack(
                model: ReportNftViewModel(
                    nftService: model.nftService,
                    assetData: model.assetData,
                    onComplete: model.onReportComplete
                )
            )
		}
        .sheet(item: $model.isPresentingInfoSheet) {
            InfoSheetScene(model: InfoSheetModelFactory.create(from: $0))
        }
    }
}

// MARK: - UI

extension CollectibleScene {
    private var headerSectionView: some View {
        Section {
            NftImageView(
                assetImage: model.assetImage,
                isImageLoaded: $model.isImageLoaded
            )
            .aspectRatio(1, contentMode: .fill)
        } header: {
            Spacer()
        } footer: {
            HeaderButtonsView(buttons: model.headerButtons, action: model.onSelectHeaderButton(type:))
                .padding(.top, .medium)
                .padding(.bottom, .small)
        }
        .frame(maxWidth: .infinity)
        .textCase(nil)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets())
        .contextMenu(model.imageContextMenuItems)
    }

    private var statusSectionView: some View {
        Section {
            AssetStatusView(model: model.scoreViewModel, action: model.onSelectStatus)
        }
    }

    private var assetInfoSectionView: some View {
        Section {
            ListItemView(field: model.collectionField)

            ListItemImageView(
                title: model.networkField.title.text,
                subtitle: model.networkField.value.text,
                assetImage: model.networkAssetImage
            )

            if let contractRow = model.contractRow {
                infoRowView(contractRow)
            }
            infoRowView(model.tokenIdRow)
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

    @ViewBuilder
    private func infoRowView(_ row: CollectibleInfoRow) -> some View {
        switch row.action {
        case .explorer(let explorerContext):
            ListItemView(field: row.field)
                .explorerContext(explorerContext)
        case .copy(let copyValue):
            ListItemView(field: row.field)
                .contextMenu(.copy(value: copyValue, onCopy: model.onSelectCopyValue))
        }
    }
}
