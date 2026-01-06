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
            
            if model.canSign, let banner = model.assetBannerViewModel.allBanners.first {
                Section {
                    BannerView(
                        banner: banner,
                        action: model.onSelectBanner
                    )
                }
                .listRowInsets(.zero)
            }

            if model.showStatus {
                Section {
                    AssetStatusView(model: model.scoreViewModel, action: model.onSelectTokenStatus)
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
                
                if model.showPriceAlerts {
                    NavigationLink(
                        value: Scenes.AssetPriceAlert(asset: model.assetData.asset),
                        label: {
                            ListItemView(
                                title: model.priceAlertsViewModel.priceAlertsTitle,
                                subtitle: model.priceAlertsViewModel.priceAlertCount
                            )
                        }
                    )
                }

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

                    if model.showPendingUnconfirmedBalance {
                        ListItemView(
                            title: model.assetDataModel.pendingUnconfirmedBalanceTitle,
                            subtitle: model.assetDataModel.pendingUnconfirmedBalanceTextWithSymbol,
                            infoAction: model.onSelectPendingUnconfirmedInfo
                        )
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
                    .listRowInsets(.assetListRowInsets)
            }

            if model.showResources {
                Section(model.resourcesTitle) {
                    ListItemView(
                        title: model.energyTitle,
                        subtitle: model.energyText
                    )

                    ListItemView(
                        title: model.bandwidthTitle,
                        subtitle: model.bandwidthText
                    )
                }
            }

            if model.showTransactions {
                TransactionsList(
                    explorerService: model.explorerService,
                    model.transactions,
                    currency: model.assetDataModel.currencyCode
                )
                .listRowInsets(.assetListRowInsets)
            } else {
                Section {
                    Spacer()
                    EmptyContentView(model: model.emptyContentModel)
                        .padding(.bottom, .extraLarge)
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
        .contentMargins([.top], .small, for: .scrollContent)
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
            with: HStack(spacing: .space12) {
                EmojiView(color: Colors.grayVeryLight, emoji: "💰")
                    .frame(size: .image.asset)
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
