// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import Style
import PrimitivesComponents
import Localization

public struct AssetScene: View {
    private let model: AssetSceneViewModel

    public init(model: AssetSceneViewModel) {
        self.model = model
    }

    public var body: some View {
        List {
            Section { } header: {
                WalletHeaderView(
                    model: model.assetHeaderModel,
                    isHideBalanceEnalbed: .constant(false),
                    onHeaderAction: model.onSelectHeader,
                    onInfoAction: model.onSelectWalletHeaderInfo
                )
                .padding(.top, .small)
                .padding(.bottom, .medium)
            }
            .cleanListRow()
            Section {
                BannerView(
                    banners: model.allBanners,
                    action: model.onSelectBanner,
                    closeAction: model.onCloseBanner
                )
            }
            if model.showStatus {
                Section {
                    NavigationCustomLink(with:
                        ListItemImageView(
                            title: Localized.Transaction.status,
                            subtitle: model.scoreViewModel.status,
                            subtitleStyle: model.scoreViewModel.statusStyle,
                            assetImage: model.scoreViewModel.assetImage,
                            infoAction: { model.onSelectTokenStatus() }
                        )
                    ) {
                        model.onSelectTokenStatus()
                    }
                }
            }
            
            if model.showManageToken {
                Section(Localized.Common.manage) {
                    NavigationCustomLink(with:
                        ListItemView(
                            title: model.pinText,
                            imageStyle: .list(assetImage: AssetImage(placeholder: model.pinImage))
                        )
                    ) {
                        model.onSelectPin()
                    }
                    NavigationCustomLink(with:
                        ListItemView(
                            title: model.enableText,
                            imageStyle: .list(assetImage: AssetImage(placeholder: model.enableImage))
                        )
                    ) {
                        model.onSelectEnable()
                    }
                }
            }
            
            Section {
                NavigationLink(
                    value: Scenes.Price(asset: model.assetModel.asset),
                    label: { PriceListItemView(model: model.priceItemViewModel) }
                )
                .accessibilityIdentifier("price")

                if model.canOpenNetwork {
                    NavigationLink(
                        value: Scenes.Asset(asset: model.assetModel.asset.chain.asset),
                        label: { networkView }
                    )
                } else {
                    networkView
                }
            }

            if model.showBalances {
                Section(model.balancesTitle) {
                    ListItemView(
                        title: model.assetDataModel.availableBalanceTitle,
                        subtitle: model.assetDataModel.availableBalanceTextWithSymbol
                    )

                    if model.showStakedBalance {
                        stakeView
                    }

                    if model.showReservedBalance, let url = model.reservedBalanceUrl {
                        SafariNavigationLink(url: url) {
                            ListItemView(
                                title: model.assetDataModel.reservedBalanceTitle,
                                subtitle: model.assetDataModel.reservedBalanceTextWithSymbol
                            )
                        }
                    }
                }
            } else if model.assetDataModel.isStakeEnabled {
                stakeViewEmpty
            }

            if model.showTransactions {
                TransactionsList(
                    explorerService: model.explorerService,
                    model.transactions
                )
                .listRowInsets(.assetListRowInsets)
            } else {
                Section {
                    Spacer()
                    EmptyContentView(model: model.emptyConentModel)
                }
                .cleanListRow()
            }
        }
        .refreshable {
            await model.fetch()
        }
        .taskOnce(model.fetchOnce)
        .listSectionSpacing(.compact)
        .navigationTitle(model.title)
    }
}

// MARK: - UI Components

extension AssetScene {
    private var networkView: some View {
        ListItemImageView(
            title: model.networkTitle,
            subtitle: model.networkText,
            assetImage: model.networkAssetImage,
            imageSize: .list.image
        )
    }

    private var stakeView: some View {
        NavigationCustomLink(
            with: ListItemView(title: model.stakeTitle, subtitle: model.assetDataModel.stakeBalanceTextWithSymbol),
            action: { model.onSelectHeader(.stake) }
        )
        .accessibilityIdentifier("stake")
    }
    
    private var stakeViewEmpty: some View {
        NavigationCustomLink(
            with: HStack {
                EmojiView(color: Colors.grayVeryLight, emoji: "💰")
                    .frame(width: Sizing.image.asset, height: Sizing.image.asset)
                ListItemView(
                    title: model.stakeTitle,
                    subtitle: model.stakeAprText,
                    subtitleStyle: TextStyle(font: .callout, color: Colors.green)
                )
            },
            action: { model.onSelectHeader(.stake) }
        )
    }
}
