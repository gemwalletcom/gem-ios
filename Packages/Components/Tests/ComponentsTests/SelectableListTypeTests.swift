// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing

@testable import Components

struct TestItem: Identifiable, Equatable, Sendable {
    let id: Int

    init(_ id: Int) {
        self.id = id
    }
}

@Test()
func selectableListTypeItemTests() async throws {
    let items = [TestItem(1), TestItem(2)]
    #expect(SelectableListType.plain(items).items == items)

    let items2 = [TestItem(3), TestItem(4)]
    let sectionedList = SelectableListType.section([
        ListSection(id: "1", title: "Section 1", image: nil, values: items),
        ListSection(id: "2", title: "Section 2", image: nil, values: items2)
    ])
    #expect(sectionedList.items == items + items2)
}
