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
    
    private var model: TransactionDetailViewModel {
        return TransactionDetailViewModel(
            model: TransactionViewModel(
                explorerService: ExplorerService.standard,
                transaction: transactions.first!,
                formatter: .medium
            ),
            priceStore: input.priceStore
        )
    }
    private let input: TransactionSceneInput
    
    @State private var showShareSheet = false
    @State private var isPresentingInfoSheet: InfoSheetType? = .none
    
    public init(input: TransactionSceneInput) {
        self.input = input
        _transactions = Query(input.transactionRequest)
    }
    
    public var body: some View {
        VStack {
            List {
                Section {
                    ListItemView(title: model.dateField, subtitle: model.date)
                    HStack(spacing: Spacing.small) {
                        ListItemView(
                            title: model.statusField,
                            subtitle: model.statusText,
                            subtitleStyle: model.statusTextStyle,
                            infoAction: onStatusInfo
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
                    
                    if let participantField = model.participantField, let account = model.participantAccount {
                        AddressListItemView(
                            title: participantField,
                            style: .short,
                            account: account,
                            explorerService: ExplorerService.standard
                        )
                    }
                    
                    if model.showMemoField {
                        MemoListItemView(memo: model.memo)
                    }

                    ListItemImageView(
                        title: model.networkField,
                        subtitle: model.network,
                        assetImage: model.networkAssetImage
                    )

                    ListItemView(
                        title: model.networkFeeField,
                        subtitle: model.networkFeeText,
                        subtitleExtra: model.networkFeeFiatText,
                        infoAction: onNetworkFeeInfo
                    )
                } header: {
                    switch model.headerType {
                    case .amount:
                        HStack {
                            Spacer()
                            TransactionHeaderView(type: model.headerType)
                                .padding(.bottom, 16)
                            Spacer()
                        }
                    case .swap:
                        Section {
                            TransactionHeaderView(type: model.headerType)
                                .padding()
                        }
                        .frame(maxWidth: .infinity)
                        .textCase(nil)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                    case .nft:
                        HStack {
                            Spacer()
                            TransactionHeaderView(type: model.headerType)
                                .padding(.bottom, 16)
                            Spacer()
                        }
                    }
                }
                
                Section {
                    NavigationOpenLink(
                        url: model.transactionExplorerUrl,
                        with: Text(model.transactionExplorerText)
                            .tint(Colors.black)
                    )
                }
            }
        }
        .background(Colors.grayBackground)
        .navigationTitle(model.title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showShareSheet.toggle()
                } label: {
                    Images.System.share
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [model.transactionExplorerUrl.absoluteString])
        }
        .sheet(item: $isPresentingInfoSheet) {
            InfoSheetScene(model: InfoSheetViewModel(type: $0))
        }
    }
}

// MARK: - Actions

extension TransactionScene {
    func onNetworkFeeInfo() {
        isPresentingInfoSheet = .networkFee(model.chain)
    }

    func onStatusInfo() {
        isPresentingInfoSheet = .transactionState(
            imageURL: model.assetImage.imageURL,
            placeholder: model.assetImage.placeholder,
            state: model.transactionState
        )
    }
}

