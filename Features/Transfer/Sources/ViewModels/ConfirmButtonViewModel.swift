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
         onAction: @MainActor @Sendable @escaping (ConfrimButtonActionType) -> Void
     ) {
         self.state = state
         self.icon = icon
         self.perform = { onAction(Self.actionType(for: state)) }
     }

     var title: String {
         switch Self.actionType(for: state) {
         case .buy: Localized.Errors.insufficientFunds
         case .confirm: Localized.Transfer.confirm
         case .retry: Localized.Common.tryAgain
         }
     }

     var type: ButtonType { Self.buttonType(for: state) }

     func action() { perform() }
 }

 // MARK: - Private

 extension ConfirmButtonViewModel {
     private static func actionType(
         for state: StateViewType<TransactionInputViewModel>
     ) -> ConfrimButtonActionType {
         if state.isError { return .retry }

         switch buttonType(for: state) {
         case .primary:   return .confirm
         case .secondary: return .buy
         }
     }

     private static func buttonType(
           for state: StateViewType<TransactionInputViewModel>
       ) -> ButtonType {
           let isPrimary: Bool = {
               switch state {
               case .noData, .loading, .error: true
               case let .data(model): model.transferAmount?.isSuccess ?? false
               }
           }()
           return isPrimary ? .primary(state, isDisabled: state.isNoData) : .secondary
       }
 }
