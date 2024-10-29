// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

struct SwapChangeView: View {
    
    @Binding var fromId: String
    @Binding var toId: String
    
    var body: some View {
        Button {
            swap(&fromId, &toId)
        } label: {
            Images.Actions.swap
        }
    }
}
