// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Localization
import Style
import PrimitivesComponents

struct FullMessageScene: View {
    let model: FullMessageViewModel
    
    var body: some View {
        ScrollView {
            Text(model.displayMessage)
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .dismissToolbarItem(title: .cancel, placement: .topBarLeading)
        .background(Colors.grayBackground)
        .navigationTitle(Localized.SignMessage.message)
        .navigationBarTitleDisplayMode(.inline)
    }
}
