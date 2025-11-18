// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
@testable import Transfer
import Primitives
import PrimitivesTestKit
import SwiftUI

public extension TransferExecutionViewModel {
    static func mock(
        transferStateService: TransferStateService = .mock(),
        execution: TransferExecution = .mock(),
        isPresentingConfirmTransfer: Binding<ConfirmTransferPresentation?> = .constant(nil)
    ) -> TransferExecutionViewModel {
        TransferExecutionViewModel(
            transferStateService: transferStateService,
            execution: execution,
            isPresentingConfirmTransfer: isPresentingConfirmTransfer
        )
    }
}
