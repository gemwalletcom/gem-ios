// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Combine
import Style

struct NotificationsScene: View {
    
    let model: NotificationsViewModel
    @State public var notificationsEnabled: Bool
    
    init(
        model: NotificationsViewModel
    ) {
        self.model = model
        _notificationsEnabled = State(initialValue: model.isPushNotificationsEnabled)
    }
    
    var body: some View {
        List {
            Toggle(
                model.title,
                isOn: $notificationsEnabled
            )
            .toggleStyle(AppToggleStyle())
        }
        .onChange(of: notificationsEnabled) { (_, newValue) in
            model.preferences.isPushNotificationsEnabled = newValue
            
            switch newValue {
            case true:
                Task {
                    notificationsEnabled = try await model.requestPermissions()
                    try await model.update()
                }
            case false:
                Task {
                    try await model.update()
                }
            }
        }
        .navigationTitle(model.title)
    }
}

//struct NotificationsScene_Previews: PreviewProvider {
//    static var previews: some View {
//        NotificationsScene()
//    }
//}
