// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style

public struct SecurityScene: View {
    @State private var model: SecurityViewModel

    public init(model: SecurityViewModel) {
        self.model = model
    }

    public var body: some View {
        List {
            Section {
                Toggle(model.authenticationTitle, isOn: $model.isEnabled)
                    .toggleStyle(AppToggleStyle())

                if model.isEnabled {
                    Picker(model.lockPeriodTitle, selection: $model.lockPeriod) {
                        ForEach(model.allLockPeriods) {
                            Text($0.title)
                        }
                    }
                    .pickerStyle(.menu)

                    Toggle(model.privacyLockTitle, isOn: $model.isPrivacyLockEnabled)
                        .toggleStyle(AppToggleStyle())
                }
            }

            Section {
                Toggle(model.hideBalanceTitle, isOn: $model.isHideBalanceEnabled)
                    .toggleStyle(AppToggleStyle())
            }
        }
        .onChange(of: model.isEnabled, onToggleBiometrics)
        .onChange(of: model.isPrivacyLockEnabled, onToggleSecurityLock)
        .alert("",
               isPresented: $model.isPresentingError.mappedToBool(),
               actions: {},
               message: { Text(model.errorTitle) }
        )
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
