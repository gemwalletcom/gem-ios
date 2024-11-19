// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

public struct SwapChangeView: View {
    
    @Binding var fromId: String?
    @Binding var toId: String?
    
    public init(
        fromId: Binding<String?> = .constant(.none),
        toId: Binding<String?> = .constant(.none)
    ) {
        _fromId = fromId
        _toId = toId
    }
    
    public var body: some View {
        Button {
            swap(&fromId, &toId)
        } label: {
            Images.Actions.swap
                .renderingMode(.template)
                .foregroundStyle(Colors.gray)
        }
    }
}
