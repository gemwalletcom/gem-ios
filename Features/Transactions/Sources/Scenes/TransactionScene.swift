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
                model: model.headerItemModel,
                action: model.onSelectTransactionHeader
            )

            if model.headerItemModel.showSwapAgain {
                Section {
                    StateButton(
                        text: model.headerItemModel.swapAgainText,
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
                    MemoListItemView(memo: memoModel.memo)
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
