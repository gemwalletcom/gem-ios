// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import Primitives
import Staking

struct StakeValidatorsScene: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var model: StakeValidatorsViewModel
    
    var body: some View {
        List {
            ForEach(model.list) { section in
                Section(section.section) {
                    ForEach(section.values) { value in
                        ValidatorSelectionView(value: value, selection: model.currentValidator?.id) {
                            model.selectValidator?($0)
                            dismiss()
                        }
                    }
                }
            }
        }
        .navigationTitle(model.title)
    }
}
