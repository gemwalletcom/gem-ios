// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public struct SectionListView<Section, SectionHeader, RowContent>: View
    where Section: ListSectionRepresentable,
          SectionHeader: View,
          RowContent: View {
    
    let sections: [Section]
    let sectionHeader: ((Section) -> SectionHeader)?
    let rowContent: (Section.Item) -> RowContent
    
    public init(
        sections: [Section],
        @ViewBuilder sectionHeader: @escaping (Section) -> SectionHeader,
        @ViewBuilder rowContent: @escaping (Section.Item) -> RowContent
    ) {
        self.sections = sections
        self.sectionHeader = sectionHeader
        self.rowContent = rowContent
    }
    
    public var body: some View {
        ForEach(sections) { section in
            SwiftUI.Section {
                ForEach(section.items) { item in
                    rowContent(item)
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
        @ViewBuilder rowContent: @escaping (Section.Item) -> RowContent
    ) {
        self.sections = sections
        self.sectionHeader = nil
        self.rowContent = rowContent
    }
}

// Single section view for simple cases
public struct ListSingleSectionView<Item, RowContent>: View
    where Item: ListItemRepresentable,
          RowContent: View {
    
    let items: [Item]
    let rowContent: (Item) -> RowContent
    
    public init(
        items: [Item],
        @ViewBuilder rowContent: @escaping (Item) -> RowContent
    ) {
        self.items = items
        self.rowContent = rowContent
    }
    
    public var body: some View {
        ForEach(items) { item in
            rowContent(item)
        }
    }
}
