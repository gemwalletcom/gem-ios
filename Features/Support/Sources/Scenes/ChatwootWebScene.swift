// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components

struct ChatwootWebScene: View {
    @State var model: ChatwootWebViewModel
    
    init(model: ChatwootWebViewModel) {
        _model = State(wrappedValue: model)
    }
    
    var body: some View {
        ZStack {
            ChatwootWebView(model: model)
            
            if model.isLoading {
                LoadingView()
            }
        }
    }
}
