// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import Primitives

public struct StakeValidatorsScene: View {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var model: StakeValidatorsViewModel

    public init(model: StakeValidatorsViewModel) {
        _model = StateObject(wrappedValue: model)
    }

    public var body: some View {
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
