// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Components
import Style
import Store
import GRDB
import GRDBQuery
import Primitives

struct TransactionScene: View {
    
    @Query<TransactionsRequest>
    var transactions: [Primitives.TransactionExtended]
    
    var model: TransactionDetailViewModel {
        return TransactionDetailViewModel(
            model: TransactionViewModel(
                transaction: transactions.first!,
                formatter: .medium
            )
        )
    }
    
    let input: TransactionSceneInput
    
    init(
        input: TransactionSceneInput
    ) {
        self.input = input
        _transactions = Query(input.transactionRequest, in: \.db.dbQueue)
    }
    
    @State private var showShareSheet = false

    var body: some View {
        VStack {
            List {
                Section {
                    ListItemView(title: model.dateField, subtitle: model.date)
                    HStack(spacing: Spacing.small) {
                        ListItemView(
                            title: model.statusField,
                            subtitle: model.status,
                            subtitleStyle: model.statusTextStyle
                        )
                        switch model.statusType {
                        case .none:
                            EmptyView()
                        case .progressView:
                            ListItemProgressView(size: .regular, tint: Colors.orange)
                        case .image(let image):
                            image
                        }
                    }
                    
                    if let participantField = model.participantField, let account = model.participantAccount {
                        AddressListItem(title: participantField, style: .short, account: account)
                    }
                    
                    if model.showMemoField {
                        MemoListItem(memo: model.memo)
                    }
                    HStack {
                        ListItemView(title: model.networkField, subtitle: model.network)
                        AssetImageView(assetImage: model.networkAssetImage, size: Sizing.list.image)
                    }
                    ListItemView(
                        title: model.networkFeeField,
                        subtitle: model.networkFeeText,
                        subtitleExtra: model.networkFeeFiatText
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
                    }
                }
                
                Section {
                    Button(role: .none) {
                        UIApplication.shared.open(model.transactionExplorerUrl)
                    } label: {
                        HStack {
                            Text(model.transactionExplorerText)
                                .tint(Colors.black)
                        }
                    }
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
                    Image(systemName: SystemImage.share)
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [model.transactionExplorerUrl.absoluteString])
        }
    }
}
