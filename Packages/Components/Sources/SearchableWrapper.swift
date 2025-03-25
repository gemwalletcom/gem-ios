// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public struct SearchableWrapper<Content: View>: View {
    @Environment(\.isSearching) private var isSearching
    @Environment(\.dismissSearch) private var dismissSearch
    
    private let content: () -> Content
    private let onChangeIsSearching: (Bool) -> Void
    private let onDismissSearch: (@escaping () -> Void) -> Void
    
    public init(
        @ViewBuilder content: @escaping () -> Content,
        onChangeIsSearching: @escaping (Bool) -> Void,
        onDismissSearch: @escaping (@escaping () -> Void) -> Void
    ) {
        self.content = content
        self.onChangeIsSearching = onChangeIsSearching
        self.onDismissSearch = onDismissSearch
    }
    
    public var body: some View {
        content()
            .onAppear {
                onDismissSearch {
                    dismissSearch()
                }
            }
            .onChange(of: isSearching) { oldValue, newValue in
                if newValue != oldValue {
                    onChangeIsSearching(newValue)
                }
            }
    }
}
