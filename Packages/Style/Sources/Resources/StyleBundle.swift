// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import os.log

// ref: https://fatbobman.com/en/posts/unified_management_of_resources_in_multi-package_projects/

private class BundleFinder {}

public extension Foundation.Bundle {
    static let style: Bundle = {
        let bundleName = "Style_Style"
        let candidates = generateCandidateURLs(for: BundleFinder.self, bundleName: bundleName)

        for candidate in candidates.compactMap({ $0 }) {
            let bundlePath = candidate.appendingPathComponent(bundleName + ".bundle")
            if let bundle = Bundle(url: bundlePath) {
                return bundle
            } else {
                os_log("Bundle not found at path: %@", bundlePath.path)
            }
        }

        fatalError("Unable to find bundle named \(bundleName)")
    }()

    private static func generateCandidateURLs(for bundleFinderClass: AnyClass, bundleName: String) -> [URL?] {
        let bundleFinder = Bundle(for: bundleFinderClass)
        return [
            Bundle.main.resourceURL,
            bundleFinder.resourceURL,
            Bundle.main.bundleURL,
            bundleFinder.resourceURL?
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .deletingLastPathComponent(),
            bundleFinder.resourceURL?
                .deletingLastPathComponent()
                .deletingLastPathComponent(),
            bundleFinder.resourceURL?
                .deletingLastPathComponent()
        ]
    }
}

