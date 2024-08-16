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
}
