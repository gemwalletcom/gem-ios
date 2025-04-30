// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import Components

struct SecurityReminderScene: View {
    @State private var model: SecurityReminderViewModel
    @State private var isPresentingUrl: URL? = nil
    
    init(model: SecurityReminderCreateWalletViewModel) {
        self.model = model
    }
    
    var body: some View {
        VStack(spacing: .medium) {
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
                    .listRowInsets(.assetListRowInsets)
                }
            }
            .contentMargins([.top], .extraSmall, for: .scrollContent)
            .listSectionSpacing(.custom(.medium))
            
            Spacer()
            
            VStack(alignment: .leading) {
                Toggle(isOn: $model.isConfirmed) {
                    OnboardingHeaderTitle(title: model.checkmarkTitle, alignment: .center)
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
        .padding(.bottom, .scene.bottom)
        .background(Colors.grayBackground)
        .navigationTitle(model.title)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("", systemImage: SystemImage.info) {
                    isPresentingUrl = model.docsUrl
                }
            }
        }
        .safariSheet(url: $isPresentingUrl)
    }
}

#Preview(body: {
    SecurityReminderScene(model: SecurityReminderCreateWalletViewModel(onNext: {}))
})
