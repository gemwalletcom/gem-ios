// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import PrimitivesComponents

public struct AmountNavigationStack: View {
    @State private var model: AmountSceneViewModel
    
    public init(model: AmountSceneViewModel) {
        _model = State(initialValue: model)
    }
    
    public var body: some View {
        NavigationStack {
            AmountNavigationView(model: model)
                .toolbar {
                    ToolbarDismissItem(
                        title: .cancel,
                        placement: .navigationBarLeading
                    )
                }
        }
    }
}