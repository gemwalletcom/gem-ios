// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Keystore

struct LockPeriodSelectionScene: View {
    @Environment(\.dismiss) var dismiss

    @Binding private var model: LockPeriodSelectionViewModel

    init(model: Binding<LockPeriodSelectionViewModel>) {
        _model = model
    }

    var body: some View {
        List(model.allPeriods) { option in
            ListItemSelectionView(
                title: option.title,
                titleExtra: .none,
                subtitle: .none,
                subtitleExtra: .none,
                value: option,
                selection: model.selectedPeriod
            ) {
                onSelect(period: $0)
            }
        }
        .listSectionSpacing(.compact)
        .navigationTitle(model.title)
    }
}

// MARK: - Actions

extension LockPeriodSelectionScene {
    private func onSelect(period: LockPeriod) {
        model.update(period: period)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        LockPeriodSelectionScene(model: .constant(.init(service: BiometryAuthenticationService())))
    }
}
