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
        }
        .onChange(of: model.isEnabled, onToggleEnable)
        .alert(item: $model.isPresentingError) {
            Alert(title: Text("Transfer Error"), message: Text($0))
        }
        .navigationTitle(model.title)
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
