// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives

final class ArrayPrimitivesTests {
    @Test
    func testSplitInSubArrays() {
        #expect([1].splitInSubArrays(into: 2) == [[1], []])
        #expect([1, 2, 3, 4].splitInSubArrays(into: 2) == [[1, 3], [2, 4]])
    }

    @Test
    func testChunks() {
        #expect([1].chunks(2) == [[1]])
        #expect([1, 2, 3, 4].chunks(2) == [[1, 2], [3, 4]])
    }

    @Test
    func testShuffleInGroups() {
        let input = ["1", "2", "3", "4"]

        #expect(input.shuffleInGroups(groupSize: 4).count == 4)
        #expect(input.shuffleInGroups(groupSize: 3).count == 4)
        #expect(input.shuffleInGroups(groupSize: 2).count == 4)

        #expect(Array(input.shuffleInGroups(groupSize: 2).prefix(2)).asSet() == ["1", "2"].asSet())
        #expect(Array(input.shuffleInGroups(groupSize: 2).suffix(2)).asSet() == ["3", "4"].asSet())
    }
}

