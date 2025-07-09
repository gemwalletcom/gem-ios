import Testing
import Primitives
import PrimitivesTestKit

@testable import DiscoverAssetsService

struct DiscoverAssetsServiceTests {
    @Test
    func excludeDefaultAccounts() throws {
        let filteredAccounts: [Account] = [.mock(chain: .bitcoin), .mock(chain: .solana), .mock(chain: .ton), .mock(chain: .aptos)].excludeDefaultAccounts()

        #expect(filteredAccounts.count == 2)
        #expect(filteredAccounts.contains(.mock(chain: .ton)))
        #expect(filteredAccounts.contains(.mock(chain: .aptos)))
    }
}
