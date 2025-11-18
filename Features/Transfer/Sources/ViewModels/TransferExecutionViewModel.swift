// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import Components

@MainActor
public final class TransferExecutionViewModel {
    private let transferStateService: TransferStateService
    public let execution: TransferExecution

    @Binding public var isPresentingConfirmTransfer: ConfirmTransferPresentation?

    public init(
        transferStateService: TransferStateService,
        execution: TransferExecution,
        isPresentingConfirmTransfer: Binding<ConfirmTransferPresentation?>
    ) {
        self.transferStateService = transferStateService
        self.execution = execution
        self._isPresentingConfirmTransfer = isPresentingConfirmTransfer
    }

    public var listItemModel: ListItemModel {
        TransferExecutionItemViewModel(execution: execution).listItemModel
    }

    func onTap() {
        switch execution.state {
        case .executing, .success: break
        case .error(let error): retry(error: error)
        }
    }

    public func dismiss() {
        Task {
            await transferStateService.remove(execution: execution)
        }
    }

    private func retry(error: Error) {
        isPresentingConfirmTransfer = .retry(execution.transferData, error: error)
        dismiss()
    }
}
