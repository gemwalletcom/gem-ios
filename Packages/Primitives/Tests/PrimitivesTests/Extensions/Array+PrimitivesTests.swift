// Copyright (c). Gem Wallet. All rights reserved.

import XCTest
import Primitives

final class ArrayPrimitivesTests: XCTestCase {

    func testSplitInSubArrays() {
        XCTAssertEqual([1].splitInSubArrays(into: 2), [[1], []])
        XCTAssertEqual([1, 2, 3, 4].splitInSubArrays(into: 2), [[1,3], [2,4]])
    }
    
    func testChunks() {
        XCTAssertEqual([1].chunks(2), [[1]])
        XCTAssertEqual([1, 2, 3, 4].chunks(2), [[1,2], [3,4]])
    }
    
    func testShuffleInGroups() {
        let input = ["1", "2", "3", "4"]
        
        XCTAssertEqual(input.shuffleInGroups(groupSize: 4).count, 4)
        XCTAssertEqual(input.shuffleInGroups(groupSize: 3).count, 4)
        XCTAssertEqual(input.shuffleInGroups(groupSize: 2).count, 4)
        
        XCTAssertEqual(Array(input.shuffleInGroups(groupSize: 2).prefix(2)).asSet(), ["1", "2"].asSet())
        XCTAssertEqual(Array(input.shuffleInGroups(groupSize: 2).suffix(2)).asSet(), ["3", "4"].asSet())
    }
}
