// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Observation
import Components
import SwiftUI
import Style
import Localization
import Transfer

@Observable
public final class TransferHandler: TransferHandleable {
    @MainActor
    public var toastMessage: ToastMessage?

    public init() {}

    @MainActor
    public func handle(state: TransferState) async {
        switch state {
        case .executing(let type):
            toastMessage = ToastMessage(
                title: executingTitle(for: type),
                image: SystemImage.paperplane,
                duration: .infinity
            )
        case .completed(let type):
            toastMessage = ToastMessage(
                title: completedTitle(for: type),
                image: SystemImage.checkmarkCircle
            )
        case .failed:
            toastMessage = ToastMessage(
                title: Localized.Errors.errorOccured,
                image: SystemImage.xmarkCircle
            )
        }
    }

    private func executingTitle(for type: TransferDataType) -> String {
        switch type {
        case .perpetual(_, let perpetualType):
            switch perpetualType {
            case .open: "Opening position..."
            case .close: "Closing position..."
            }
        default: "Transaction executing..."
        }
    }

    private func completedTitle(for type: TransferDataType) -> String {
        switch type {
        case .perpetual(_, let perpetualType):
            switch perpetualType {
            case .open: "Position opened successfully"
            case .close: "Position closed successfully"
            }
        default: "Sent successfully"
        }
    }
}
