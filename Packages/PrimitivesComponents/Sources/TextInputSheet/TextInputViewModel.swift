// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

@MainActor
public protocol TextInputViewModelProtocol: Observable, AnyObject {
    var title: String { get }
    var placeholder: String { get }
    var footer: String? { get }
    var text: String { get set }
    var isLoading: Bool { get }
    var isActionDisabled: Bool { get }
    var errorMessage: String? { get set }

    func action() async
}

extension TextInputViewModelProtocol {
    public var footer: String? { nil }
}
