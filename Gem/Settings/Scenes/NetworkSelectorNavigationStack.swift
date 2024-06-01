// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components

struct NetworkSelectorNavigationStack: View {
    
    let chains: [Chain]
    @State var selectedChain: Binding<Chain>
    @State var isPresenting: Binding<Bool>
    var action: ((String) -> Void)?

    var body: some View {
        NavigationStack {
            List {
                ForEach(chains) { chain in
                    NavigationCustomLink(with: ChainView(chain: chain)) {
                        selectedChain.wrappedValue = chain
                        isPresenting.wrappedValue = false
                    }
                }
            }
            .navigationTitle(Localized.Settings.Networks.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(Localized.Common.cancel) {
                        isPresenting.wrappedValue = false
                    }
                }
            }
        }
    }
}
