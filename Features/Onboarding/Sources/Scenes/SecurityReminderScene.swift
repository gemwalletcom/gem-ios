// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import Components

struct SecurityReminderScene: View {
    
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
            .listSectionSpacing(.compact)
            
            Spacer()
            
            VStack(alignment: .leading) {
                Toggle(isOn: $model.isConfirmed) {
                    OnboardingHeaderTitle(title: model.checkMarkTitle, alignment: .leading)
                }
                .toggleStyle(CheckboxStyle())
                
                StateButton(
                    text: model.buttonTitle,
                    viewState: model.buttonState,
                    action: model.onNext
                )
            }
            .frame(maxWidth: .scene.button.maxWidth)
            
        }
        .navigationTitle(model.title)
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview(body: {
    SecurityReminderScene(model: SecurityReminderCreateWalletViewModel(onNext: {}))
})
