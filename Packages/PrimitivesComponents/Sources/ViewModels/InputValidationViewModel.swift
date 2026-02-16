// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Validators

public enum InputValidationMode {
    case onDemand, manual
}

@MainActor
@Observable
public final class InputValidationViewModel {
    public var text: String = "" {
        didSet {
            onChangeText(oldValue, text)
        }
    }

    public private(set) var error: (any Error)?
    
    private let mode: InputValidationMode
    private var validators: [any TextValidator]

    public init(
        mode: InputValidationMode = .manual,
        validators: [any TextValidator] = []
    ) {
        self.mode = mode
        self.validators = validators
    }
}

// MARK: - Public

extension InputValidationViewModel {
    public var isValid: Bool { error == nil }
    public var isInvalid: Bool { error != nil }

    public func validate() -> (any Error)? {
        do {
            try validators.forEach { try $0.validate(text) }
            return nil
        } catch {
            return error
        }
    }

    @discardableResult
    public func update() -> Bool {
        error = validate()
        return isValid
    }

    @discardableResult
    public func update(text: String) -> Bool {
        self.text = text
        return update()
    }

    public func update(validators: [any TextValidator]) {
        self.validators = validators
        guard text.isNotEmpty else {
            update(error: nil)
            return
        }
        update()
    }

    public func update(error: (any Error)?) {
        self.error = error
    }
}

// MARK: - Private

extension InputValidationViewModel {
    private func onChangeText(_ oldText: String, _ text: String) {
        guard text.isNotEmpty else {
            update(error: nil)
            return
        }

        switch mode {
        case .onDemand:
            update()
        case .manual:
            // clear error for every field change
            if isInvalid && oldText != text {
                update(error: nil)
            }
        }
    }
}
