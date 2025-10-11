// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import Primitives
import Components

public struct TransactionHeaderListItemView: View {
    private let headerType: TransactionHeaderType
    private let showClearHeader: Bool
    private let action: VoidAction

    public init(
        headerType: TransactionHeaderType,
        showClearHeader: Bool,
        action: VoidAction = nil
    ) {
        self.headerType = headerType
        self.showClearHeader = showClearHeader
        self.action = action
    }
    
    public init(model: TransactionHeaderItemModel, action: VoidAction = nil) {
        self.headerType = model.headerType
        self.showClearHeader = model.showClearHeader
        self.action = action
    }

    public var body: some View {
        if showClearHeader {
            Section {} header: {
                TransactionHeaderView(type: headerType)
                    .padding(.top, .small)
            }
            .cleanListRow()
        } else {
            Section {
                TransactionHeaderView(type: headerType)
            }
            .ifLet(action) { view, action in
                Button(action: action) {
                    view
                }
            }
        }
    }
}

#Preview {
    List {
        TransactionHeaderListItemView(
            headerType:
                    .swap(
                        from: .init(
                            assetImage: .image(Images.Chains.abstract), amount: "300", fiatAmount: "300$"
                        ),
                        to: .init(
                            assetImage: .image(Images.Chains.arbitrum), amount: "200", fiatAmount: "200$"
                        )
                    ),
            showClearHeader: true
        )
    }
}
