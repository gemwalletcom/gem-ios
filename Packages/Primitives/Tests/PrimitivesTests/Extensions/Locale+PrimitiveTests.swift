// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import BigInt
import Foundation

final class Locale_PrimitivesTests {
    @Test
    func testUsageLanguageIdentifier() {
        #expect(Locale.US.usageLanguageIdentifier() == "en")
        #expect(Locale.UK.usageLanguageIdentifier() == "en")
        #expect(Locale.EN_CH.usageLanguageIdentifier() == "en")
        #expect(Locale.PT_BR.usageLanguageIdentifier() == "pt-BR")
        #expect(Locale.FR.usageLanguageIdentifier() == "fr")
        #expect(Locale.ZH_Simplifier.usageLanguageIdentifier() == "zh-Hans")
        #expect(Locale.ZH_Singapore.usageLanguageIdentifier() == "zh-Hans")
        #expect(Locale.ZH_Traditional.usageLanguageIdentifier() == "zh-Hant")
    }

    @Test
    func testAppstoreLanguageIdentifier() throws {
        #expect(try Locale.US.appstoreLanguageIdentifier() == "en-US")
        #expect(try Locale.UK.appstoreLanguageIdentifier() == "en-US")
        #expect(try Locale.FR.appstoreLanguageIdentifier() == "fr-FR")
        #expect(try Locale.IT.appstoreLanguageIdentifier() == "it")
        #expect(try Locale.ZH_Simplifier.appstoreLanguageIdentifier() == "zh-Hans")
        #expect(try Locale.ZH_Traditional.appstoreLanguageIdentifier() == "zh-Hant")
    }
}
