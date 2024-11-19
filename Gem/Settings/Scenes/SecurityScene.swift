// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import Keystore

struct SecurityScene: View {
    @State private var model: SecurityViewModel

    init(model: SecurityViewModel) {
        self.model = model
    }

    var body: some View {
        List {
            Section {
                Toggle(model.authenticationTitle, isOn: $model.isEnabled)
                    .toggleStyle(AppToggleStyle())

                if model.isEnabled {
                    NavigationLink(value: model.lockPeriodModel.selectedPeriod) {
                        ListItemView(
                            title: model.lockPeriodModel.title,
                            subtitle: model.lockPeriodModel.selectedPeriod.title
                        )
                    }

                    Toggle(model.privacyLockTitle, isOn: $model.isPrivacyLockEnabled)
                        .toggleStyle(AppToggleStyle())
                }
            }

            Section {
                Toggle(model.balacePrivacyTitle, isOn: $model.isBalancePrivacyEnabled)
                    .toggleStyle(AppToggleStyle())
            }
        }
        .onChange(of: model.isEnabled, onToggleBiometrics)
        .onChange(of: model.isPrivacyLockEnabled, onToggleSecurityLock)
        .alert(item: $model.isPresentingError) {
            Alert(title: Text(model.errorTitle), message: Text($0))
        }
        .navigationDestination(for: LockPeriod.self) { _ in
            LockPeriodSelectionScene(model: $model.lockPeriodModel)
        }
        .navigationTitle(model.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Actions

extension SecurityScene {
    private func onToggleBiometrics() {
        Task {
            await model.toggleBiometrics()
        }
    }

    private func onToggleSecurityLock() {
        model.togglePrivacyLock()
    }
}

#Preview {
    SecurityScene(model: .init())
}
