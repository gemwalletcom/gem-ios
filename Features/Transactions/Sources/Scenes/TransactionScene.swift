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

public struct TransactionScene: View {
    @Query<TransactionsRequest>
    private var transactions: [Primitives.TransactionExtended]

    private let input: TransactionSceneInput

    @State private var detailModel: TransactionDetailViewModel? = nil
    @State private var sceneModel: TransactionSceneViewModel? = nil

    public init(input: TransactionSceneInput) {
        self.input = input
        _transactions = Query(input.transactionRequest)
    }

    public var body: some View {
        VStack {
            if let detailModel = detailModel, let sceneModel = sceneModel {
                List {
                    TransactionHeaderListItemView(
                        headerType: detailModel.headerType,
                        showClearHeader: detailModel.showClearHeader
                    )
                    Section {
                        ListItemView(title: detailModel.dateField, subtitle: detailModel.date)
                        HStack(spacing: .small) {
                            ListItemView(
                                title: detailModel.statusField,
                                subtitle: detailModel.statusText,
                                subtitleStyle: detailModel.statusTextStyle,
                                infoAction: sceneModel.onStatusInfo
                            )
                            switch detailModel.statusType {
                            case .none:
                                EmptyView()
                            case .progressView:
                                LoadingView(tint: Colors.orange)
                            case .image(let image):
                                image
                            }
                        }

                        if let recipientAddressViewModel = detailModel.recipientAddressViewModel {
                            AddressListItemView(model: recipientAddressViewModel)
                        }

                        if detailModel.showMemoField {
                            MemoListItemView(memo: detailModel.memo)
                        }

                        ListItemImageView(
                            title: detailModel.networkField,
                            subtitle: detailModel.network,
                            assetImage: detailModel.networkAssetImage
                        )
                        
                        if let item = detailModel.providerListItem {
                            ListItemImageView(
                                title: item.title,
                                subtitle: item.subtitle,
                                assetImage: item.assetImage
                            )
                        }
                        
                        ListItemView(
                            title: detailModel.networkFeeField,
                            subtitle: detailModel.networkFeeText,
                            subtitleExtra: detailModel.networkFeeFiatText,
                            infoAction: sceneModel.onNetworkFeeInfo
                        )
                    }
                    Section {
                        SafariNavigationLink(url: detailModel.transactionExplorerUrl) {
                            Text(detailModel.transactionExplorerText)
                                .tint(Colors.black)
                        }
                    }
                }
                .contentMargins([.top], .small, for: .scrollContent)
                .listSectionSpacing(.compact)
                .background(Colors.grayBackground)
                .navigationTitle(detailModel.title)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: sceneModel.onShare) {
                            Images.System.share
                        }
                    }
                }
                .sheet(isPresented: Binding(
                    get: { sceneModel.isPresentingShareSheet },
                    set: { sceneModel.isPresentingShareSheet = $0 }
                )) {
                    ShareSheet(activityItems: [detailModel.transactionExplorerUrl.absoluteString])
                }
                .sheet(item: Binding(
                    get: { sceneModel.isPresentingInfoSheet },
                    set: { sceneModel.isPresentingInfoSheet = $0 }
                )) {
                    InfoSheetScene(model: InfoSheetViewModel(type: $0))
                }
            } else {
                LoadingView()
            }
        }
        .onAppear {
            if let transaction = transactions.first {
                let detailViewModel = TransactionDetailViewModel(
                    model: TransactionViewModel(
                        explorerService: ExplorerService.standard,
                        transaction: transaction,
                        formatter: .auto
                    )
                )
                self.detailModel = detailViewModel
                self.sceneModel = TransactionSceneViewModel(detailViewModel: detailViewModel)
            }
        }
        .onChange(of: transactions) { _, newTransactions in
            if let transaction = newTransactions.first {
                let detailViewModel = TransactionDetailViewModel(
                    model: TransactionViewModel(
                        explorerService: ExplorerService.standard,
                        transaction: transaction,
                        formatter: .auto
                    )
                )
                self.detailModel = detailViewModel
                self.sceneModel = TransactionSceneViewModel(detailViewModel: detailViewModel)
            }
        }
    }
}
