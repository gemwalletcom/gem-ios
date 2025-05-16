// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public struct SearchableWrapper<Content: View>: View {
    @Environment(\.isSearching) private var isSearching
    @Environment(\.dismissSearch) private var dismissSearch
    
    @Binding private var isSearchingBinding: Bool
    @Binding private var dismissSearchBinding: Bool
    
    private let content: () -> Content
    
    public init(
        @ViewBuilder content: @escaping () -> Content,
        isSearching: Binding<Bool>,
        dismissSearch: Binding<Bool>
    ) {
        self.content = content
        _isSearchingBinding = isSearching
        _dismissSearchBinding = dismissSearch
    }
    
    public var body: some View {
        content()
            .onChange(of: isSearching) { oldValue, isSearching in
                if oldValue != isSearching {
                    isSearchingBinding = isSearching
                }
            }
            .onChange(of: dismissSearchBinding) { _, _ in
                dismissSearch()
            }
    }
}
