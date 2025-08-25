// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

/// When using in a List, be sure to use `.id(UUID())` to ensure proper rendering and updates.
/// That is knwown bugs in List+ProgressView
public struct ListItemLoadingView: View {
    let clearBackground: Bool

    public init(clearBackground: Bool = true) {
        self.clearBackground = clearBackground
    }

    public var body: some View {
        LoadingView()
            .frame(maxWidth: .infinity)
            .listRowSeparator(.hidden)
            .if(clearBackground) {
                $0.listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
    }
}

#Preview {
    return List {
        Text("any text")
        Text("some text")
        Text("more text")
        Section {
            ListItemLoadingView()
        }
    }
    .listStyle(.insetGrouped)
}
