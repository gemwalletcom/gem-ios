// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components

public struct ChatwootWebScene: View {
    @State var model: ChatwootWebViewModel
    
    public init(model: ChatwootWebViewModel) {
        _model = State(wrappedValue: model)
    }
    
    public var body: some View {
        ZStack {
            ChatwootWebView(model: model)
            
            if model.isLoading {
                LoadingView()
            }
        }
    }
}
