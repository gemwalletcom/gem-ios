// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Localization
import Primitives

struct ConnectionScene: View {
    @Environment(\.dismiss) private var dismiss
    let model: ConnectionSceneViewModel
    
    var body: some View {
        List {
            Section {
                ConnectionView(model: model.model)
            }
            Section {
                ListItemView(title: model.walletField, subtitle: model.walletText)
                ListItemView(title: model.dateField, subtitle: model.dateText)
            }
            Section {
                Button(model.disconnectTitle, role: .destructive) {
                    Task {
                        await disconnect()
                    }
                    dismiss()
                }
            }
        }
        .listSectionSpacing(.compact)
        .navigationTitle(model.title)
    }
    
    func disconnect() async {
        do {
            try await model.disconnect()
        } catch {
            debugLog("disconnect error: \(error)")
        }
    }
}
