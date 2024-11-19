// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components
import Primitives
import Swap

struct SwapTokenView: View {
    
    let model: SwapTokenViewModel
    @Binding var text: String
    var showLoading: Bool = false
    var disabledTextField: Bool = false
    var onBalanceAction: (() -> Void)
    var onSelectAssetAction: ((SelectAssetSwapType) -> Void)
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                VStack(alignment: .center) {
                    Button(role: .none) {
                        onSelectAssetAction(model.type)
                    } label: {
                        HStack {
                            AssetImageView(assetImage: model.assetImage)
                            Text(model.symbol)
                            SwapChevronView()
                        }
                    }
                }
                .padding(.vertical, 8)
                
                HStack {
                    TextField(showLoading ? "" : String.zero, text: $text)
                        .keyboardType(.decimalPad)
                        .foregroundColor(Colors.black)
                        .font(.system(size: 36))
                        .fontWeight(.semibold)
                        .disabled(disabledTextField)
                        .multilineTextAlignment(.trailing)
                    if showLoading {
                        LoadingView()
                    }
                }
            }.padding(.bottom, 2)
                HStack {
                    Button(action: onBalanceAction) {
                        Text(model.availableBalanceText)
                            .font(.system(size: 13))
                            .fontWeight(.medium)
                            .foregroundColor(Colors.secondaryText)
                    }
                    Spacer()
                    Text(model.fiatBalance(amount: text))
                        .font(.system(size: 13))
                        .fontWeight(.medium)
                        .foregroundColor(Colors.secondaryText)
            }
        }
    }
    var chevronView: some View {
        Images.Actions.receive
            .colorMultiply(Colors.gray)
            .frame(width: 12, height: 12)
            .opacity(0.8)
    }
}

//#Preview {
//    SwapTokenView()
//}
