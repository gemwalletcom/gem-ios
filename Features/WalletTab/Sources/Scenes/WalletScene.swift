// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import Store
import Style
import InfoSheet
import PrimitivesComponents
import Localization

public struct WalletScene: View {
    private var model: WalletSceneViewModel

    public init(model: WalletSceneViewModel) {
        self.model = model
    }

    public var body: some View {
        @Bindable var preferences = model.observablePreferences

        List {
            Section { } header: {
                WalletHeaderView(
                    model: model.walletHeaderModel,
                    isHideBalanceEnalbed: $preferences.isHideBalanceEnabled,
                    onHeaderAction: model.onHeaderAction,
                    onInfoAction: model.onSelectWatchWalletInfo
                )
                .padding(.top, .small)
            }
            .cleanListRow()

            if ($preferences.isDeveloperEnabled.wrappedValue || preferences.preferences.isPerpetualEnabled) && model.wallet.isMultiCoins {
                Section {
                    PerpetualsPreviewView(wallet: model.wallet)
                } header: {
                    HeaderNavigationLinkView(title: "PERPETUALS", destination: Scenes.Perpetuals())
                }
            }
            
            if let banner = model.walletBannersModel.priorityBanner {
                Section {
                    BannerView(
                        banner: banner,
                        action: model.onBanner
                    )
                }
                .listRowInsets(.zero)
            }

            if model.showPinnedSection {
                Section {
                    WalletAssetsList(
                        assets: model.sections.pinned,
                        currencyCode: model.currencyCode,
                        onHideAsset: model.onHideAsset,
                        onPinAsset: model.onPinAsset,
                        showBalancePrivacy: $preferences.isHideBalanceEnabled
                    )
                    .listRowInsets(.assetListRowInsets)
                } header: {
                    HStack {
                        model.pinImage
                        Text(model.pinnedTitle)
                    }
                }
            }

            Section {
                WalletAssetsList(
                    assets: model.sections.assets,
                    currencyCode: model.currencyCode,
                    onHideAsset: model.onHideAsset,
                    onPinAsset: model.onPinAsset,
                    showBalancePrivacy: $preferences.isHideBalanceEnabled
                )
                .listRowInsets(.assetListRowInsets)
            } header: {
                if model.isLoadingAssets {
                    LoadingTextView(isAnimating: .constant(true))
                        .listRowInsets(.assetListRowInsets)
                        .textCase(nil)
                }
            } footer: {
                ListButton(
                    title: model.manageTokenTitle,
                    image: model.manageImage,
                    action: model.onSelectManage
                )
                .accessibilityIdentifier("manage")
                .padding(.medium)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .refreshable {
            model.fetch()
        }
        .taskOnce {
            model.fetch()
        }
    }
}
