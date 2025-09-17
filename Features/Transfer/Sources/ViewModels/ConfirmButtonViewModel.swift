// Copyright (c). Gem Wallet. All rights reserved.

 import Primitives
 import SwiftUI
 import Localization
 import Components
 import Style

 struct ConfirmButtonViewModel: StateButtonViewable {
     private let perform: @MainActor @Sendable () -> Void
     private let state: StateViewType<TransactionInputViewModel>

     let icon: Image?

     init(
         state: StateViewType<TransactionInputViewModel>,
         icon: Image?,
         onAction: @MainActor @Sendable @escaping () -> Void
     ) {
         self.state = state
         self.icon = icon
         self.perform = { onAction() }
     }

     var title: String {
         switch Self.actionType(for: state) {
         case .confirm: Localized.Transfer.confirm
         case .retry: Localized.Common.tryAgain
         }
     }

     var type: ButtonType {
        let isDisabled = state.value?.transferAmount?.isFailure ?? false
        return .primary(state, isDisabled: isDisabled)
    }

     func action() { perform() }
 }

 // MARK: - Private

 extension ConfirmButtonViewModel {
     private static func actionType(
         for state: StateViewType<TransactionInputViewModel>
     ) -> ConfrimButtonActionType {
         if state.isError { return .retry }
         return .confirm
     }
 }
