// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components

struct ChipsView<Data: RandomAccessCollection, Content: View>: View where Data.Element: Identifiable {
    let data: Data
    let spacing: CGFloat
    let content: (Data.Element) -> Content

    var body: some View {
        FlowLayout(spacing: spacing) {
            ForEach(data, content: content)
        }
    }
}

// MARK: - Previews

#Preview {
    ChipsView(data: ["test1", "test2", "test3", "test4", "test5", "test6", "test7", "test8", "test9", "test10"],
             spacing: 8) {
        Text($0)
            .padding(8)
            .background(.red)
            .clipShape(Capsule())
    }
}
