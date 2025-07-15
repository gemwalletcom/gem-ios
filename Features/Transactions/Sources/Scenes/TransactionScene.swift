// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Components
import Style
import Store
import GRDBQuery
import Primitives
import InfoSheet
import PrimitivesComponents
import ExplorerService

// TODO: - move related logic to view model, e.g. @Query, presenation states, make model as observable
public struct TransactionScene: View {
    @Query<TransactionsRequest>
    private var transactions: [Primitives.TransactionExtended]

    @State private var isPresentingShareSheet = false
    @State private var isPresentingInfoSheet: InfoSheetType? = .none
    @Binding private var isPresentingSelectedAssetType: SelectedAssetType?

    private let input: TransactionSceneInput

    private var model: TransactionDetailViewModel {
        TransactionDetailViewModel(
            model: TransactionViewModel(
                explorerService: ExplorerService.standard,
                transaction: transactions.first!,
                formatter: .auto
            )
        )
    }

    public init(input: TransactionSceneInput, isPresentingSelectedAssetType: Binding<SelectedAssetType?>) {
        self.input = input
        _transactions = Query(input.transactionRequest)
        _isPresentingSelectedAssetType = isPresentingSelectedAssetType
    }

    public var body: some View {
        VStack {
            List {
                TransactionHeaderListItemView(
                    headerType: model.headerType,
                    showClearHeader: model.showClearHeader,
                    action: onSelectTransactionHeader
                )
                Section {
                    ListItemView(title: model.dateField, subtitle: model.date)
                    HStack(spacing: .small) {
                        ListItemView(
                            title: model.statusField,
                            subtitle: model.statusText,
                            subtitleStyle: model.statusTextStyle,
                            infoAction: onSelectStatusInfo
                        )
                        switch model.statusType {
                        case .none:
                            EmptyView()
                        case .progressView:
                            LoadingView(tint: Colors.orange)
                        case .image(let image):
                            image
                        }
                    }

                    if let recipientAddressViewModel = model.recipientAddressViewModel {
                        AddressListItemView(model: recipientAddressViewModel)
                    }

                    if model.showMemoField {
                        MemoListItemView(memo: model.memo)
                    }

                    ListItemImageView(
                        title: model.networkField,
                        subtitle: model.network,
                        assetImage: model.networkAssetImage
                    )

                    if let item = model.providerListItem {
                        ListItemImageView(
                            title: item.title,
                            subtitle: item.subtitle,
                            assetImage: item.assetImage
                        )
                    }

                    ListItemView(
                        title: model.networkFeeField,
                        subtitle: model.networkFeeText,
                        subtitleExtra: model.networkFeeFiatText,
                        infoAction: onSelectNetworkFeeInfo
                    )
                }
                Section {
                    SafariNavigationLink(url: model.transactionExplorerUrl) {
                        Text(model.transactionExplorerText)
                            .tint(Colors.black)
                    }
                }
            }
            .contentMargins([.top], .small, for: .scrollContent)
            .listSectionSpacing(.compact)
            .background(Colors.grayBackground)

            if model.showSwapAgain {
                Spacer()
                StateButton(
                    text: model.swapAgain,
                    type: .primary(.normal),
                    action: onSelectTransactionHeader
                )
                .frame(maxWidth: .scene.button.maxWidth)
            }
        }
        .if(model.showSwapAgain) {
            $0.padding(.bottom, .scene.bottom)
        }
        .navigationTitle(model.title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isPresentingShareSheet.toggle()
                } label: {
                    Images.System.share
                }
            }
        }
        .sheet(isPresented: $isPresentingShareSheet) {
            ShareSheet(activityItems: [model.transactionExplorerUrl.absoluteString])
        }
        .sheet(item: $isPresentingInfoSheet) {
            InfoSheetScene(model: InfoSheetViewModel(type: $0))
        }
    }
}

// MARK: - Actions

extension TransactionScene {
    func onSelectTransactionHeader() {
        switch model.headerType {
        case .swap:
            let transaction = model.model.transaction
            let fromAsset = transaction.asset
            let toAsset = transaction.assets.first(where: { $0.id != fromAsset.id })
            isPresentingSelectedAssetType = .swap(fromAsset, toAsset)
        case .nft, .amount:
            break
        }
    }

    func onSelectNetworkFeeInfo() {
        isPresentingInfoSheet = .networkFee(model.chain)
    }

    func onSelectStatusInfo() {
        isPresentingInfoSheet = .transactionState(
            imageURL: model.assetImage.imageURL,
            placeholder: model.assetImage.placeholder,
            state: model.transactionState
        )
    }
}
