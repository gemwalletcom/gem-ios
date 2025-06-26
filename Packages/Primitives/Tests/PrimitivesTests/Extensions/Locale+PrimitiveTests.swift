// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import BigInt
import Foundation

struct Locale_PrimitivesTests {
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
        #expect(Locale.US.appstoreLanguageIdentifier() == "en-US")
        #expect(Locale.UK.appstoreLanguageIdentifier() == "en-US")
        #expect(Locale.FR.appstoreLanguageIdentifier() == "fr-FR")
        #expect(Locale.IT.appstoreLanguageIdentifier() == "it")
        #expect(Locale.ZH_Simplifier.appstoreLanguageIdentifier() == "zh-Hans")
        #expect(Locale.ZH_Traditional.appstoreLanguageIdentifier() == "zh-Hant")
        #expect(Locale.AR_SA.appstoreLanguageIdentifier() == "ar-SA")
    }
}
