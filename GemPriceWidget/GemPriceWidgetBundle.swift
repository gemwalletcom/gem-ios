// Copyright (c). Gem Wallet. All rights reserved.

import WidgetKit
import SwiftUI

@main
struct GemPriceWidgetBundle: WidgetBundle {
    var body: some Widget {
        SmallPriceWidget()
        MediumPriceWidget()
    }
}
