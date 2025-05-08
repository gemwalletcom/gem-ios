// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing

@testable import Components

@Test()
func selectableListTypeItemTests() async throws {
    let items = [1, 2]
    #expect(SelectableListType.plain(items).items == items)

    let items2 = [3, 4]
    let sectionedList = SelectableListType.section([
        ListSection(id: "1", title: "Section 1", image: nil, values: items),
        ListSection(id: "2", title: "Section 2", image: nil, values: items2)
    ])
    #expect(sectionedList.items == items + items2)
}
