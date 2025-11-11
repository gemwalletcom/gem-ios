// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum ConfirmTransferPresentation: Sendable {
    case confirm(TransferData)
    case retry(TransferData, error: Error)

    public var transferData: TransferData {
        switch self {
        case .confirm(let data): return data
        case .retry(let data, _): return data
        }
    }
}

extension ConfirmTransferPresentation: Equatable, Identifiable {
    public var id: String { transferData.id }

    public static func == (lhs: ConfirmTransferPresentation, rhs: ConfirmTransferPresentation) -> Bool {
        switch (lhs, rhs) {
        case (.confirm, .confirm), (.retry, .retry): lhs.id == rhs.id
        default: false
        }
    }
}
