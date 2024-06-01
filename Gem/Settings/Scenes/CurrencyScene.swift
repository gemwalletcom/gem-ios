// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives

struct CurrencyScene: View {
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var model: CurrencySceneViewModel
    
    init(
        model: CurrencySceneViewModel
    ) {
        self.model = model
    }
    
    var body: some View {
        List {
            ForEach(model.list) { section in
                Section(section.section) {
                    ForEach(section.values) { currency in
                        SelectionListItemView(
                            title: currency.title,
                            subtitle: .none,
                            value: currency.value,
                            selection: model.currency
                        ) {
                            model.currency = $0
                        }
                    }
                }
            }
        }
        .navigationTitle(model.title)
    }
}

//struct CurrencyScene_Previews: PreviewProvider {
//    static var previews: some View {
//        CurrencyScene()
//    }
//}
