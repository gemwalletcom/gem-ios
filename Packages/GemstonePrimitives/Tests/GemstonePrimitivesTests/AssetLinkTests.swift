// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import XCTest
import Primitives
import Gemstone

@testable import GemstonePrimitives

final class AssetLinkTests: XCTestCase {

    func testHostForWebsite() {
        let assetLink1 = AssetLink(name: "website", url: "https://www.example.com")
        XCTAssertEqual(assetLink1.host(for: .website), "example.com")

        let assetLink2 = AssetLink(name: "website", url: "http://example.com")
        XCTAssertEqual(assetLink2.host(for: .website), "example.com")

        let assetLink3 = AssetLink(name: "website", url: "https://sub.domain.example.com")
        XCTAssertEqual(assetLink3.host(for: .website), "sub.domain.example.com")
        
        let assetLink4 = AssetLink(name: "website", url: "https://www.example.co.uk")
        XCTAssertEqual(assetLink4.host(for: .website), "example.co.uk")
    }

    func testHostForWebsiteWithPath() {
        let assetLink1 = AssetLink(name: "website", url: "https://www.example.com/some-page")
        XCTAssertEqual(assetLink1.host(for: .website), "example.com")

        let assetLink2 = AssetLink(name: "website", url: "http://example.com/profile?id=123")
        XCTAssertEqual(assetLink2.host(for: .website), "example.com")

        let assetLink3 = AssetLink(name: "website", url: "https://sub.domain.example.com/path/to/resource")
        XCTAssertEqual(assetLink3.host(for: .website), "sub.domain.example.com")

        let assetLink4 = AssetLink(name: "website", url: "https://www.example.co.uk/about-us")
        XCTAssertEqual(assetLink4.host(for: .website), "example.co.uk")

        let assetLink5 = AssetLink(name: "website", url: "https://www.example.com:8080/custom-port")
        XCTAssertEqual(assetLink5.host(for: .website), "example.com")
    }

    func testHostForNilSocialReturnsNil() {
        let assetLink = AssetLink(name: "website", url: "https://www.example.com")
        XCTAssertNil(assetLink.host(for: nil))
    }
}
