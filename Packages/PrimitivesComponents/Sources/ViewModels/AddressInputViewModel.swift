// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Validators
import Components
import Style
import Localization

@Observable
@MainActor
public final class AddressInputViewModel {

    let placeholder: String
    public let nameRecordViewModel: NameRecordViewModel

    public var chain: Chain {
        didSet { onChangeChain() }
    }

    var inputModel: InputValidationViewModel

    public init(
        chain: Chain,
        nameService: any NameServiceable,
        placeholder: String,
        validators: [any TextValidator] = []
    ) {
        self.chain = chain
        self.placeholder = placeholder
        self.nameRecordViewModel = NameRecordViewModel(nameService: nameService)
        self.inputModel = InputValidationViewModel(
            mode: .manual,
            validators: validators
        )
    }

    public var text: String {
        get { inputModel.text }
        set { inputModel.text = newValue }
    }

    public var nameResolveState: NameRecordState {
        nameRecordViewModel.state
    }

    public var isValid: Bool {
        switch nameResolveState {
        case .none: inputModel.isValid && inputModel.text.isNotEmpty
        case .loading, .error: false
        case .complete: true
        }
    }

    public var resolvedAddress: String {
        if let resolved = nameResolveState.result {
            return resolved.address
        }
        return inputModel.text.trim()
    }

    @discardableResult
    public func update() -> Bool {
        inputModel.update()
    }

    public func update(text: String) {
        inputModel.update(text: text)
    }

    public func update(error: (any Error)?) {
        inputModel.update(error: error)
    }

    @discardableResult
    public func validate() -> Bool {
        isValid || update()
    }

    public func updateValidators(_ validators: [any TextValidator]) {
        inputModel.update(validators: validators)
    }
}

extension AddressInputViewModel {
    public var shouldShowInputActions: Bool {
        inputModel.text.isEmpty
    }

    func onSelectPaste() {
        guard let address = UIPasteboard.general.string else { return }
        update(text: address)
    }

    func onTextChange(_: String, newText: String) {
        nameRecordViewModel.resolve(name: newText, chain: chain)
    }

    func onNameResolveStateChange(_: NameRecordState, newState: NameRecordState) {
        if newState.result != nil {
            update(error: nil)
        }
    }
}

// MARK: - Private

extension AddressInputViewModel {
    private func onChangeChain() {
        nameRecordViewModel.reset()
        let currentText = text

        inputModel = InputValidationViewModel(
            mode: .manual,
            validators: [
                .required(requireName: placeholder),
                .address(Asset(chain))
            ]
        )
        text = currentText

        if nameRecordViewModel.canResolveName(name: currentText) {
            nameRecordViewModel.resolve(name: currentText, chain: chain)
        } else if currentText.isNotEmpty {
            inputModel.update()
        }
    }
}
