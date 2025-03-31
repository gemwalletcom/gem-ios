// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

public struct TransactionHeaderListItemView: View {
    let headerType: TransactionHeaderType
    let showClearHeader: Bool

    public init(
        headerType: TransactionHeaderType,
        showClearHeader: Bool
    ) {
        self.headerType = headerType
        self.showClearHeader = showClearHeader
    }

    public var body: some View {
        HStack(spacing: .zero) {
            Spacer(minLength: 0)
            TransactionHeaderView(type: headerType)
            Spacer(minLength: 0)
        }
        .if(showClearHeader) {
            $0.cleanListRow()
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
