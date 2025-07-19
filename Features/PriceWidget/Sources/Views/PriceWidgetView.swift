// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import WidgetKit
import Style
import Components
import Formatters

public struct PriceWidgetView: View {
    private let viewModel: PriceWidgetViewModel
    
    public init(entry: PriceWidgetEntry, widgetFamily: WidgetFamily) {
        self.viewModel = PriceWidgetViewModel(entry: entry, widgetFamily: widgetFamily)
    }
    
    init(viewModel: PriceWidgetViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        Group {
            switch viewModel.widgetFamily {
            case .systemSmall:
                SmallPriceWidgetView(viewModel: viewModel)
            default:
                MediumPriceWidgetView(viewModel: viewModel)
            }
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}

// MARK: - Widget Extension


struct PriceWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PriceWidgetView(entry: .placeholder(widgetFamily: .systemSmall), widgetFamily: .systemSmall)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("Small")
            
            PriceWidgetView(entry: .placeholder(), widgetFamily: .systemMedium)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("Medium")
        }
    }
}
