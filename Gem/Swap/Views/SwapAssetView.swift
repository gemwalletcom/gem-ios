// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components

struct SwapTokenView: View {
    
    let model: SwapTokenViewModel
    @Binding var text: String
    var showLoading: Bool = false
    var disabledTextField: Bool = false
    var balanceAction: (() -> Void)
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                VStack(alignment: .center) {
                    Button(role: .none) {
                        //
                    } label: {
                        HStack {
                            AssetImageView(assetImage: model.assetImage)
                            Text(model.symbol)
                            Images.Actions.receive
                                .colorMultiply(Colors.gray)
                                .frame(width: 12, height: 12)
                                .opacity(0.8)
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
                    Button(action: balanceAction) {
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
}

//#Preview {
//    SwapTokenView()
//}
