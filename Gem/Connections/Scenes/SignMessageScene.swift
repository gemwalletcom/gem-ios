// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style

struct SignMessageScene: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let model: SignMessageSceneViewModel
    
    var body: some View {
        VStack {
            List {
                Section {
                    ListItemView(title: Localized.Common.wallet, subtitle: model.walletText)
                    ListItemView(title: Localized.Transfer.network, subtitle: model.networkText)
                }
                Section(Localized.SignMessage.message) {
                    Text(model.message)
                }
            }
            
            Button(role: .none) { sign() } label: {
                HStack {
                    //Image(systemName: model.buttonImage)
                    Text(model.buttonTitle)
                }
            }
            .buttonStyle(BlueButton())
            .padding(.bottom, Spacing.scene.bottom)
            .frame(maxWidth: Spacing.scene.button.maxWidth)
        }
        .padding(.bottom, Spacing.scene.bottom)
        .background(Colors.grayBackground)
        .navigationTitle(Localized.SignMessage.title)
    }
    
    func sign() {
        do {
            try model.signMessage()
            dismiss()
        } catch {
            NSLog("sign message error \(error)")
        }
    }
}

//#Preview {
//    SignMessageScene()
//}
