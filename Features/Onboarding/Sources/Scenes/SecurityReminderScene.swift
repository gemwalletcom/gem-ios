// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import Components
import Localization
import Primitives

struct SecurityReminderScene: View {
    @State private var model: SecurityReminderViewModel
    
    init(model: SecurityReminderViewModel) {
        self.model = model
    }
    
    var body: some View {
        List {
            CalloutView(style: .header(title: model.message))
                .cleanListRow()
            
            ForEach(model.items) { item in
                Section {
                    ListItemView(
                        title: TextValue(text: item.title, style: .headline),
                        titleExtra: TextValue(text: item.subtitle, style: .bodySecondary),
                        imageStyle: item.image
                    )
                }
            }
        }
        .safeAreaView {
            StateButton(
                text: Localized.Common.continue,
                action: model.onNext
            )
            .frame(maxWidth: .scene.button.maxWidth)
        }
        .contentMargins([.top], .extraSmall, for: .scrollContent)
        .listSectionSpacing(.custom(.medium))
        .navigationTitle(model.title)
        .toolbarTitleDisplayMode(.inline)
        .toolbarInfoButton(url: model.docsUrl)
    }
}

#Preview {
    SecurityReminderScene(
        model: SecurityReminderViewModelDefault(
            title: Localized.Wallet.New.title,
            onNext: {}
        )
    )
}
