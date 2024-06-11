// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style

struct ConnectionProposalScene: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let model: ConnectionProposalViewModel
    
    var body: some View {
        VStack {
            List {
                Section { } header: {
                    VStack(alignment: .center) {
                        AsyncImageView(url: model.imageUrl, size: 64)
                    }
                    .padding(.top, 8)
                }
                .frame(maxWidth: .infinity)
                .textCase(nil)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                
                Section {
                    ListItemView(title: Localized.Common.wallet, subtitle: model.walletText)
                    ListItemView(title: Localized.WalletConnect.app, subtitle: model.appText)
                    if let website = model.websiteText {
                        ListItemView(title: Localized.WalletConnect.website, subtitle: website)
                    }
                }
            }
            Button(role: .none) { accept() } label: {
                HStack {
                    Text(model.buttonTitle)
                }
            }
            .buttonStyle(.blue())
            .padding(.bottom, Spacing.scene.bottom)
            .frame(maxWidth: Spacing.scene.button.maxWidth)
            
        }
        .padding(.bottom, Spacing.scene.bottom)
        .background(Colors.grayBackground)
        .navigationTitle(model.title)
    }
    
    func accept() {
        do {
            try model.accept()
            dismiss()
        } catch {
            NSLog("accept proposal error \(error)")
        }
    }
}
