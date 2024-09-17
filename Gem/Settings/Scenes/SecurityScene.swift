// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import LocalAuthentication
import Style

struct SecurityScene: View {
    @State private var model: SecurityViewModel

    init(model: SecurityViewModel) {
        self.model = model
    }
    
    var body: some View {
        List {
            Toggle(model.authenticationTitle, isOn: $model.isEnabled)
            .toggleStyle(AppToggleStyle())

            NavigationLink(value: model.lockPeriodModel.selectedOption) {
                ListItemView(
                    title: model.lockPeriodModel.title,
                    subtitle: model.lockPeriodModel.selectedOption.title
                )
            }
        }
        .onChange(of: model.isEnabled, onToggleEnable)
        .alert(item: $model.isPresentingError) {
            Alert(title: Text("Transfer Error"), message: Text($0))
        }
        .navigationDestination(for: LockOption.self) { _ in
            LockPeriodSelectionScene(model: $model.lockPeriodModel)
        }
        .navigationTitle(model.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Actions

extension SecurityScene {
    private func onToggleEnable() {
        Task {
            await model.toggleBiometrics()
        }
    }
}

#Preview {
    SecurityScene(model: .init())
}
