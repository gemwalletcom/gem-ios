// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import Primitives

struct StakeValidatorsScene: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var model: StakeValidatorsViewModel
    
    var body: some View {
        List {
            ForEach(model.list) { section in
                Section(section.section) {
                    ForEach(section.values) { value in
                        HStack {
                            ValidatorImageView(validator: value.value)
                            ListItemSelectionView(
                                title: value.title,
                                titleExtra: .none,
                                titleTag: .none,
                                titleTagType: .none,
                                subtitle: value.subtitle,
                                subtitleExtra: .none,
                                value: value.value.id,
                                selection: model.currentValidator?.id
                            ) { _ in
                                model.selectValidator?(value.value)
                                dismiss()
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(model.title)
    }
}
