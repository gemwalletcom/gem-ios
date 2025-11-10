import Testing
import UIKit
import PrimitivesTestKit
@testable import PrimitivesComponents

struct CopyTypeViewModelTests {

    @Test
    func pasteboardOptionsNil() {
        let options = CopyTypeViewModel.pasteboardOptions(expirationTime: nil)

        #expect(options.isEmpty)
    }

    @Test
    func pasteboardOptionsWithExpiration() {
        let options = CopyTypeViewModel.pasteboardOptions(expirationTime: 60)

        #expect(options[.localOnly] as? Bool == true)
        #expect(options[.expirationDate] as? Date != nil)
    }

    @Test
    func expirationTimeInternal() {
        #expect(CopyTypeViewModel(type: .secretPhrase, copyValue: "").expirationTimeInternal == 60)
        #expect(CopyTypeViewModel(type: .privateKey, copyValue: "").expirationTimeInternal == 60)
        #expect(CopyTypeViewModel(type: .address(.mock(), address: ""), copyValue: "").expirationTimeInternal == nil)
    }
}
