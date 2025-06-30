// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public struct ListSectionView<Item: Identifiable & Sendable, Content: View>: View {
    let sections: [ListSection<Item>]
    let content: (Item) -> Content
    
    public init(
        sections: [ListSection<Item>],
        @ViewBuilder content: @escaping  (Item) -> Content
    ) {
        self.sections = sections
        self.content = content
    }
    
    public var body: some View {
        List {
            ForEach(sections) { section in
                let sectionContent = {
                    ForEach(section.values) { item in
                        content(item)
                    }
                }

                Section {
                    sectionContent()
                } header: {
                    if section.title == nil && section.image == nil {
                        EmptyView()
                    } else {
                        HStack {
                            if let image = section.image {
                                image
                            }
                            if let title = section.title {
                                Text(title)
                            }
                        }
                    }
                }
                .listRowInsets(.assetListRowInsets)
            }
        }
    }
}
