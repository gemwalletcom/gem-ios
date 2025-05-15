// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum InputValidationMode {
    case live, manual
}

@MainActor
@Observable
public final class InputValidationViewModel {
    public var text: String = "" {
        didSet {
            if text.isEmpty {
                error = nil
            } else if mode == .live {
                validate()
            }
        }
    }

    public private(set) var error: (any LocalizedError)?

    private let mode: InputValidationMode
    private var validators: [any TextValidator]

    public init(
        mode: InputValidationMode = .manual,
        validators: [any TextValidator]
    ) {
        self.mode = mode
        self.validators = validators
    }

    public var isValid: Bool { error == nil && text.isNotEmpty }
}

// MARK: - Public

extension InputValidationViewModel {

    @discardableResult
    public func validate() -> Bool {
        error = Self.validate(text, with: validators)
        return error == nil
    }

    public func update(validators: [any TextValidator]) {
        self.validators = validators
        validate()
    }

    @discardableResult
    public func update(text: String) -> Bool {
        self.text = text
        return validate()
    }

    public func update(error: (any Error)?) {
        if let error {
            if let error = error as? LocalizedError {
                self.error = error
            } else {
                self.error = UnknownValidationError()
            }
        } else {
            self.error = nil
        }
    }
}

// MARK: - Private

extension InputValidationViewModel {
    private static func validate(
        _ text: String,
        with validators: [any TextValidator]
    ) -> (any LocalizedError)? {
        guard text.isNotEmpty else { return nil }

        do {
            try validators.forEach { try $0.validate(text) }
        } catch let error as LocalizedError {
            return error
        } catch {
            return UnknownValidationError()
        }
        return nil
    }
}
