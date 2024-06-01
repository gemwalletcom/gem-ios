// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

struct AssetTitleViewViewModel {
    let name: String
    let chainName: String?
    let tokenTypeName: String?
}

struct AssetTitleView: View {
    
    let model: AssetTitleViewViewModel
    
    init(
        model: AssetTitleViewViewModel
    ) {
        self.model = model
    }
    
    var body: some View {
        VStack(spacing: 2) {
            Text(model.name)
                .foregroundColor(Colors.black)
                .fontWeight(.semibold)
                .font(.headline)
            if let chainName = model.chainName, let tokenTypeName = model.tokenTypeName {
                HStack(alignment: .center) {
                    Text(chainName)
                    Text("|")
                    Text(tokenTypeName)
                }
                .foregroundColor(Colors.secondaryText)
                .font(.system(size: 13))
                .fontWeight(.semibold)
            }
        }
        .padding(.horizontal, 4)
    }
}

//#Preview {
//    AssetTitleView()
//}

