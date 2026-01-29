// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import Components

public struct SwapAmountField {
    public let assetImage: AssetImage
    public let amount: String
    public let fiatAmount: String?
    
    public init(assetImage: AssetImage, amount: String, fiatAmount: String?) {
        self.assetImage = assetImage
        self.amount = amount
        self.fiatAmount = fiatAmount
    }
}

struct SwapAmountView: View {

    let from: SwapAmountField
    let to: SwapAmountField

    init(
        from: SwapAmountField,
        to: SwapAmountField
    ) {
        self.from = from
        self.to = to
    }

    var body: some View {
        VStack(spacing: 0) {
            SwapAmountSingleView(field: from)
            Images.Actions.receive
                .resizable()
                .colorMultiply(Colors.black)
                .frame(width: 18, height: 22)
                .scaledToFit()
                .padding(.bottom, 8)
                .offset(y: -8)
            SwapAmountSingleView(field: to)
        }
    }
}

struct SwapAmountSingleView: View {

    let field: SwapAmountField

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading) {
                Text(field.amount)
                    .foregroundColor(Colors.black)
                    .font(.system(size: 22))
                    .fontWeight(.medium)
                    .truncationMode(.middle)
                    .lineLimit(1)
                if let fiatAmount = field.fiatAmount {
                    Text(fiatAmount)
                        .font(.system(size: 12))
                        .fontWeight(.medium)
                        .foregroundColor(Colors.gray)
                }
            }
            Spacer(minLength: .extraLarge)
            AssetImageView(assetImage: field.assetImage)
        }
    }
}
