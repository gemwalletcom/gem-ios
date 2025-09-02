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
    private let model: TransactionSceneViewModel

    public init(model: TransactionSceneViewModel) {
        self.model = model
    }

    public var body: some View {
        List {
            ForEach(model.sections) { section in
                Section {
                    ForEach(section.values) { item in
                        itemView(for: item)
                    }
                }
            }
        }
        .contentMargins([.top], .small, for: .scrollContent)
        .listSectionSpacing(.compact)
        .background(Colors.grayBackground)
        .navigationTitle(model.title)
    }
    
    @ViewBuilder
    private func itemView(for item: TransactionItem) -> some View {
        if let itemModel = model.itemModel(for: item) {
            switch itemModel {
            case .header(let model):
                TransactionHeaderListItemView(
                    model: model,
                    action: self.model.onSelectTransactionHeader
                )
            case .swapButton(let model):
                StateButton(
                    text: model.text,
                    type: .primary(.normal),
                    action: self.model.onSelectTransactionHeader
                )
                .cleanListRow(topOffset: .zero)
            case .date(let model):
                ListItemView(model: model)
            case .status(let model):
                ListItemView(model: model)
            case .participant(let model):
                AddressListItemView(model: model.addressViewModel)
            case .memo(let model):
                ListItemView(model: model)
            case .network(let model):
                ListItemImageView(
                    title: model.title,
                    subtitle: model.subtitle,
                    assetImage: model.networkAssetImage
                )
            case .provider(let model):
                ListItemView(model: model)
            case .fee(let model):
                ListItemView(model: model)
            case .explorer(let model):
                SafariNavigationLink(url: model.url) {
                    Text(model.text)
                        .tint(Colors.black)
                }
            }
        }
    }
}

// TODO: - OLD TO COMPARE
/*
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
     private let model: TransactionSceneViewModel

     public init(model: TransactionSceneViewModel) {
         self.model = model
     }

     public var body: some View {
         List {
             TransactionHeaderListItemView(
                 model: model.headerViewModel.itemModel,
                 action: model.onSelectTransactionHeader
             )

             if model.headerViewModel.showSwapAgain {
                 Section {
                     StateButton(
                         text: model.headerViewModel.swapAgainText,
                         type: .primary(.normal),
                         action: model.onSelectTransactionHeader
                     )
                 }
                 .cleanListRow(topOffset: .zero)
             }

             Section {
                 ListItemView(model: model.dateItemModel)
                 ListItemView(model: model.statusItemModel)

                 if let participantModel = model.participantItemModel {
                     AddressListItemView(model: participantModel.addressViewModel)
                 }

                 if let memoModel = model.memoItemModel {
                     ListItemView(model: memoModel)
                 }

                 ListItemImageView(
                     title: model.networkItemModel.listItemModel.configuration.title,
                     subtitle:model.networkItemModel.listItemModel.configuration.subtitle,
                     assetImage: model.networkItemModel.networkAssetImage
                 )

                 if let providerModel = model.providerItemModel {
                     ListItemView(model: providerModel)
                 }

                 ListItemView(model: model.networkFeeItemModel)
             }
             Section {
                 SafariNavigationLink(url: model.explorerItemModel.url) {
                     Text(model.explorerItemModel.text)
                         .tint(Colors.black)
                 }
             }
         }
         .contentMargins([.top], .small, for: .scrollContent)
         .listSectionSpacing(.compact)
         .background(Colors.grayBackground)
         .navigationTitle(model.title)
     }
 }

 */
