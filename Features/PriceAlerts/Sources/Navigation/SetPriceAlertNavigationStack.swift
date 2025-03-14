// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Localization

public struct SetPriceAlertNavigationStack: View {
    @Environment(\.dismiss) private var dismiss

    private let model: SetPriceAlertViewModel
    
    public init(model: SetPriceAlertViewModel) {
        self.model = model
    }

    public var body: some View {
        NavigationStack {
            SetPriceAlertScene(model: model)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(Localized.Common.done) {
                        dismiss()
                    }.bold()
                }
            }
        }
    }
}
