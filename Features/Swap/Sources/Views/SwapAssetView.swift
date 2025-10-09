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
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                HStack {
                    if showLoading {
                        LoadingView()
                    }
                    TextField(showLoading ? "" : String.zero, text: $text)
                        .keyboardType(.decimalPad)
                        .foregroundColor(Colors.black)
                        .font(.system(size: 36))
                        .fontWeight(.semibold)
                        .disabled(disabledTextField)
                        .multilineTextAlignment(.leading)
                }
                
                VStack(alignment: .center) {
                    Button(role: .none) {
                        onSelectAssetAction()
                    } label: {
                        HStack {
                            AssetImageView(assetImage: model.assetImage)
                            Text(model.symbol)
                                .textStyle(
                                    TextStyle(font: .body, color: .primary, fontWeight: .medium)
                                )
                                .lineLimit(1)
                            SwapChevronView()
                        }
                    }
                }
                .padding(.vertical, .tiny)
            }.padding(.bottom, .extraSmall)
            
            HStack {
                Text(model.fiatBalance(amount: text))
                    .font(.system(size: 13))
                    .fontWeight(.medium)
                    .foregroundColor(Colors.secondaryText)
                Spacer()
                Button(action: onBalanceAction) {
                    Text(model.availableBalanceText)
                        .font(.system(size: 13))
                        .fontWeight(.medium)
                        .foregroundColor(Colors.secondaryText)
                }
            }
        }
    }
}
