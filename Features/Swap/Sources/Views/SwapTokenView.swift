// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components
import Primitives

struct SwapTokenView: View {
    let model: SwapTokenViewModel
    @Binding var text: String
    var showLoading: Bool = false
    var disabledTextField: Bool = false
    var onBalanceAction: (() -> Void)
    var onSelectAssetAction: (() -> Void)

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: .small) {
                inputView
                fiatBalanceView
            }

            VStack(alignment: .trailing, spacing: .small) {
                assetActionView
                availableBalanceView
            }
        }
    }
    
    private var inputView: some View {
        HStack {
            if showLoading {
                LoadingView()
            }
            TextField(showLoading ? "" : String.zero, text: $text)
                .keyboardType(.decimalPad)
                .foregroundStyle(Colors.black)
                .font(.app.title1)
                .disabled(disabledTextField)
                .multilineTextAlignment(.leading)
        }
    }

    private var fiatBalanceView: some View {
        Text(model.fiatBalance(amount: text))
            .lineLimit(1)
            .font(.app.callout)
            .foregroundStyle(Colors.secondaryText)
    }

    private var assetActionView: some View {
        Button(role: .none) {
            onSelectAssetAction()
        } label: {
            HStack {
                if let assetImage = model.assetImage {
                    AssetImageView(assetImage: assetImage)
                }
                Text(model.actionTitle)
                    .textStyle(TextStyle(font: .body, color: .primary, fontWeight: .medium))
                    .lineLimit(1)
                SwapChevronView()
            }
            .frame(height: .image.asset)
        }
    }

    @ViewBuilder
    private var availableBalanceView: some View {
        if let availableBalanceText = model.availableBalanceText {
            Button(action: onBalanceAction) {
                Text(availableBalanceText)
                    .lineLimit(1)
                    .font(.app.callout)
                    .foregroundStyle(Colors.secondaryText)
            }
        }
    }
}
