// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components

public struct WebViewScene: View {
    @State var model: WebSceneViewModel

    public init(url: URL) {
        _model = State(initialValue: WebSceneViewModel(url: url))
    }
    
    public var body: some View {
        ZStack {
            WebView(model: model)
            
            if model.isLoading {
                LoadingView()
            }
        }
    }
}