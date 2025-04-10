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
                Text(model.message)
                    .textStyle(.calloutSecondary)
                    .multilineTextAlignment(.center)
                    .cleanListRow(listRowInsets: EdgeInsets(top: .zero, leading: .small, bottom: .zero, trailing: .small))
                
                ForEach(model.items) { item in
                    Section {
                        ListItemView(
                            title: item.title,
                            titleExtra: item.subtitle,
                            imageStyle: item.image
                        )
                    }
                }
            }
            .listSectionSpacing(.compact)
            
            Spacer()
            
            VStack(alignment: .leading) {
                Toggle(isOn: $model.isConfirmed) {
                    Text(model.checkMarkTitle)
                        .textStyle(.calloutSecondary)
                }
                .toggleStyle(CheckboxStyle())
                
                StateButton(
                    text: model.buttonTitle,
                    viewState: model.buttonState,
                    action: {}
                )
            }
            .frame(maxWidth: .scene.button.maxWidth)
            
        }
        .navigationTitle(model.title)
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview(body: {
    SecurityReminderScene(model: SecurityReminderCreateWalletViewModel())
})
