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
            TabView(selection: $model.selectedType) {
                ChatwootWebScene(model: model.chatwootModel)
                    .tag(SupportType.support)
                WebViewScene(url: model.helpCenterURL)
                    .tag(SupportType.docs)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .background(Colors.grayBackground)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    supportTypePickerView
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("", systemImage: SystemImage.xmark, action: model.onDismiss)
                }
            }
            .task {
                await model.requestPushNotifications()
            }
            .taskOnce { Task { await model.registerSupport() } }
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
