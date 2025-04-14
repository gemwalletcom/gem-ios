// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import Components

struct SecurityReminderScene: View {
    // TODO: Fix after merging #590
    @Environment(\.openURL) private var openURL
    
    @State private var model: SecurityReminderViewModel
    
    init(model: SecurityReminderCreateWalletViewModel) {
        self.model = model
    }
    
    var body: some View {
        VStack {
            List {
                OnboardingHeaderTitle(title: model.message, alignment: .center)
                    .cleanListRow()
                
                ForEach(model.items) { item in
                    Section {
                        ListItemView(
                            title: item.title,
                            titleStyle: .headline,
                            titleExtra: item.subtitle,
                            titleStyleExtra: .bodySecondary,
                            imageStyle: item.image
                        )
                    }
                }
            }
            .contentMargins([.top], .extraSmall, for: .scrollContent)
            .listSectionSpacing(.custom(.medium))
            
            Spacer()
            
            VStack(alignment: .leading, spacing: .medium) {
                Toggle(isOn: $model.isConfirmed) {
                    OnboardingHeaderTitle(title: model.checkMarkTitle, alignment: .leading)
                }
                .toggleStyle(CheckboxStyle())
                
                StateButton(
                    text: model.buttonTitle,
                    viewState: model.buttonState,
                    action: model.onNext
                )
                .frame(height: StateButtonStyle.maxButtonHeight)
            }
            .frame(maxWidth: .scene.button.maxWidth)
            
        }
        .background(Colors.grayBackground)
        .padding(.bottom, .scene.bottom)
        .navigationTitle(model.title)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("", systemImage: SystemImage.info) {
                    openURL(model.docsUrl)
                }
            }
        }
    }
}

#Preview(body: {
    SecurityReminderScene(model: SecurityReminderCreateWalletViewModel(onNext: {}))
})
