// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import WidgetKit
import Style
import Components
import Formatters

struct MediumPriceWidgetView: View {
    private let viewModel: PriceWidgetViewModel
    
    init(viewModel: PriceWidgetViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            WidgetContentView(viewModel: viewModel)
        }
        .padding(0)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
