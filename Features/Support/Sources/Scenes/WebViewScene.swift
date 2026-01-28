// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components

struct WebViewScene: View {
    @State var model: WebSceneViewModel

    init(url: URL) {
        _model = State(initialValue: WebSceneViewModel(url: url))
    }
    
    var body: some View {
        ZStack {
            WebView(model: model)
            
            if model.isLoading {
                LoadingView()
            }
        }
    }
}