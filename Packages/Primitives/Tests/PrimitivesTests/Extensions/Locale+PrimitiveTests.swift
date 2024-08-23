// Copyright (c). Gem Wallet. All rights reserved.

import XCTest
import Primitives
import BigInt

final class Locale_PrimitivesTests: XCTestCase {

    func testUsageLanguageIdentifier() {
        XCTAssertEqual(Locale.US.usageLanguageIdentifier(), "en")
        XCTAssertEqual(Locale.UK.usageLanguageIdentifier(), "en")
        XCTAssertEqual(Locale.EN_CH.usageLanguageIdentifier(), "en")
        XCTAssertEqual(Locale.PT_BR.usageLanguageIdentifier(), "pt-BR")
        XCTAssertEqual(Locale.FR.usageLanguageIdentifier(), "fr")
        XCTAssertEqual(Locale.ZH_Simplifier.usageLanguageIdentifier(), "zh-Hans")
        XCTAssertEqual(Locale.ZH_Singapore.usageLanguageIdentifier(), "zh-Hans")
        XCTAssertEqual(Locale.ZH_Traditional.usageLanguageIdentifier(), "zh-Hant")
    }

    func testAppstoreLanguageIdentifier() {
        XCTAssertEqual(Locale.US.appstoreLanguageIdentifier(), "en-US")
        XCTAssertEqual(Locale.UK.appstoreLanguageIdentifier(), "en-US")
        XCTAssertEqual(Locale.FR.appstoreLanguageIdentifier(), "fr-FR")
        XCTAssertEqual(Locale.IT.appstoreLanguageIdentifier(), "it")
        XCTAssertEqual(Locale.ZH_Simplifier.appstoreLanguageIdentifier(), "zh-Hans")
        XCTAssertEqual(Locale.ZH_Traditional.appstoreLanguageIdentifier(), "zh-Hant")
    }
}
