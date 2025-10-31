// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Components

public struct InfoSheetActionScene<ViewModel: InfoSheetActionable>: View {
    @State private var model: ViewModel

    public init(model: ViewModel) {
        _model = State(wrappedValue: model)
    }

    public var body: some View {
        InfoSheetScene(model: model.infoSheetModel)
            .alertSheet($model.isPresentingAlertMessage)
    }
}
