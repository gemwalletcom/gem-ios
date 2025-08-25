// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public struct SectionListView<Section, SectionHeader, ListItemView>: View
    where Section: ListSectionRepresentable,
          SectionHeader: View,
          ListItemView: View {

    let sections: [Section]
    let sectionHeader: ((Section) -> SectionHeader)?
    let listItemView: (Section.Item) -> ListItemView

    public init(
        sections: [Section],
        @ViewBuilder sectionHeader: @escaping (Section) -> SectionHeader,
        @ViewBuilder listItemView: @escaping (Section.Item) -> ListItemView
    ) {
        self.sections = sections
        self.sectionHeader = sectionHeader
        self.listItemView = listItemView
    }
    
    public var body: some View {
        ForEach(sections) { section in
            SwiftUI.Section {
                ForEach(section.items) { item in
                    listItemView(item)
                }
            } header: {
                if let sectionHeader = sectionHeader {
                    sectionHeader(section)
                }
            }
        }
    }
}

// Convenience init when no section headers are needed
public extension SectionListView where SectionHeader == EmptyView {
    init(
        sections: [Section],
        @ViewBuilder listItemView: @escaping (Section.Item) -> ListItemView
    ) {
        self.sections = sections
        self.sectionHeader = nil
        self.listItemView = listItemView
    }
}

// Single section view for simple cases
public struct ListSingleSectionView<Item, ListItemView>: View
    where Item: ListItemRepresentable,
          ListItemView: View {
    
    let items: [Item]
    let listItemView: (Item) -> ListItemView
    
    public init(
        items: [Item],
        @ViewBuilder listItemView: @escaping (Item) -> ListItemView
    ) {
        self.items = items
        self.listItemView = listItemView
    }
    
    public var body: some View {
        ForEach(items) { item in
            listItemView(item)
        }
    }
}
