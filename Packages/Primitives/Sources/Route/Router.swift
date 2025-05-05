// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI

@Observable
open class Router<T: Hashable> {
    public var stack: [T] = []
    public var isPresentingAlert: AlertValue?
    
    public init(stack: [T] = []) {
        self.stack = stack
    }
    
    public func push(to view: T) {
        stack.append(view)
    }

    public func pop() {
        guard stack.isNotEmpty else { return }
        stack.removeLast()
    }
    
    public func popToRootView() {
        stack.removeAll()
    }
    
    public func navigateBack(to view: T) {
        guard let index = stack.firstIndex(of: view) else {
            return
        }
        stack = Array(stack.prefix(through: index))
    }
    
    public func presentAlert(title: String, message: String) {
        isPresentingAlert = AlertValue(title: title, message: message)
    }
}
