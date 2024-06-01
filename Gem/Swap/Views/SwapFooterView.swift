// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Components
import Style

struct SwapFooterView: View {
    
    let state: StateViewType<Bool>
    let tokenName: String
    var action: (() -> Void)
    
    var body: some View {
        VStack {
            switch state {
            case .noData:
                ZStack{}
            case .loading:
                StateLoadingView()
            case .loaded(let value):
                switch value {
                case true:
                    Button(action: action) {
                        Text(Localized.Wallet.swap)
                    }
                    .buttonStyle(BlueButton())
                case false:
                    Text(Localized.Swap.approveTokenPermission(tokenName))
                        .font(.system(size: 12))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Colors.gray)
                    Button(action: action) {
                        HStack {
                            Image(systemName: SystemImage.lock)
                            Text(Localized.Swap.approveToken(tokenName))
                        }
                    }
                    .buttonStyle(BlueButton())
                }
            case .error(let error):
                StateErrorView(error: error, message: "")
            }
        }
    }
}
