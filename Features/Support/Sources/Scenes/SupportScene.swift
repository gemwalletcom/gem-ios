// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import WebKit
import PrimitivesComponents
import Localization
import Components

public struct SupportScene: View {
    @State private var model: SupportSceneViewModel
    
    public init(model: SupportSceneViewModel) {
        _model = State(initialValue: model)
    }
    
    public var body: some View {
        NavigationView {
            VStack {
                switch model.selectedType {
                case .support:
                    ChatwootWebScene(model: model.chatwootModel)
                case .docs:
                    WebView(url: model.helpCenterURL)
                }
            }
            .background(Colors.grayBackground)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    supportTypePickerView
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(Localized.Common.done, action: model.onDismiss)
                        .bold()
                }
            }
            .task {
                await model.requestPushNotifications()
            }
        }
    }
    
    var supportTypePickerView: some View {
        Picker("", selection: $model.selectedType) {
            Text(Localized.Settings.support)
                .tag(SupportType.support)
            Text(Localized.Settings.helpCenter)
                .tag(SupportType.docs)
        }
        .pickerStyle(.segmented)
        .fixedSize()
    }
}
