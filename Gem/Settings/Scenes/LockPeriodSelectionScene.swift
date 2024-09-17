// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components

struct LockPeriodSelectionScene: View {
    @Environment(\.dismiss) var dismiss

    @Binding private var model: LockPeriodSelectionViewModel

    init(model: Binding<LockPeriodSelectionViewModel>) {
        _model = model
    }

    var body: some View {
        List(model.allOptions) { option in
            ListItemSelectionView(
                title: option.title,
                titleExtra: .none,
                subtitle: .none,
                subtitleExtra: .none,
                value: option,
                selection: model.selectedOption
            ) {
                onSelect(option: $0)
            }
        }
        .listSectionSpacing(.compact)
        .navigationTitle(model.title)
    }
}

// MARK: - Actions

extension LockPeriodSelectionScene {
    private func onSelect(option: LockOption) {
        model.selectedOption = option
        dismiss()
    }
}

#Preview {
    NavigationStack {
        LockPeriodSelectionScene(model: .constant(.init()))
    }
}
