// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import XCTest
import Primitives
import Gemstone

@testable import GemstonePrimitives

final class AssetLinkTests: XCTestCase {

    func testHostForWebsite() {
        let assetLink1 = AssetLink(name: "website", url: "https://www.example.com")
        XCTAssertEqual(assetLink1.url.asURL?.cleanHost(), "example.com")

        let assetLink2 = AssetLink(name: "website", url: "http://example.com")
        XCTAssertEqual(assetLink2.url.asURL?.cleanHost(), "example.com")

        let assetLink3 = AssetLink(name: "website", url: "https://sub.domain.example.com")
        XCTAssertEqual(assetLink3.url.asURL?.cleanHost(), "sub.domain.example.com")
        
        let assetLink4 = AssetLink(name: "website", url: "https://www.example.co.uk")
        XCTAssertEqual(assetLink4.url.asURL?.cleanHost(), "example.co.uk")
    }

    func testHostForWebsiteWithPath() {
        let assetLink1 = AssetLink(name: "website", url: "https://www.example.com/some-page")
        XCTAssertEqual(assetLink1.url.asURL?.cleanHost(), "example.com")

        let assetLink2 = AssetLink(name: "website", url: "http://example.com/profile?id=123")
        XCTAssertEqual(assetLink2.url.asURL?.cleanHost(), "example.com")

        let assetLink3 = AssetLink(name: "website", url: "https://sub.domain.example.com/path/to/resource")
        XCTAssertEqual(assetLink3.url.asURL?.cleanHost(), "sub.domain.example.com")

        let assetLink4 = AssetLink(name: "website", url: "https://www.example.co.uk/about-us")
        XCTAssertEqual(assetLink4.url.asURL?.cleanHost(), "example.co.uk")

        let assetLink5 = AssetLink(name: "website", url: "https://www.example.com:8080/custom-port")
        XCTAssertEqual(assetLink5.url.asURL?.cleanHost(), "example.com")
    }
}
