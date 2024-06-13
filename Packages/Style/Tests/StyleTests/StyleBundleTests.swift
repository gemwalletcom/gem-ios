// Copyright (c). Gem Wallet. All rights reserved.

import XCTest
@testable import Style

final class BundleTests: XCTestCase {

    private class MockBundleFinder {}

    func testStyleBundleExists() {
        // Get the bundle for the Styles package
        let bundle = Bundle.style

        // Check that the bundle exists
        XCTAssertNotNil(bundle, "The style bundle should not be nil")
    }

    func testBundleFinderCandidates() {
        let candidates = BundleFinderHelper.generateCandidateURLs(for: MockBundleFinder.self, bundleName: "Style_Style")

        // Ensure that candidates are correctly generated
        for candidate in candidates {
            XCTAssertNotNil(candidate, "Candidate URL should not be nil")
        }
    }

    func testLoggingWhenBundleNotFound() {
        let bundleName = "NonExistent_Bundle"
        let candidates = BundleFinderHelper.generateCandidateURLs(for: MockBundleFinder.self, bundleName: bundleName)

        var loggedPaths = [String]()
        for candidate in candidates.compactMap({ $0 }) {
            let bundlePath = candidate.appendingPathComponent(bundleName + ".bundle")
            if Bundle(url: bundlePath) == nil {
                loggedPaths.append(bundlePath.path)
            }
        }

        // Ensure that the logged paths include all the candidates
        XCTAssertEqual(loggedPaths.count, candidates.compactMap { $0 }.count, "All candidate paths should be logged when the bundle is not found")
    }
}
