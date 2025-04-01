// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import Primitives

public struct SwapChangeView: View {
    
    @Binding var fromId: AssetId?
    @Binding var toId: AssetId?
    
    public init(
        fromId: Binding<AssetId?> = .constant(.none),
        toId: Binding<AssetId?> = .constant(.none)
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
