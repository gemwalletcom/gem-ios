// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI

public protocol Routing: AnyObject {
    var path: NavigationPath { get set }
    var isPresentingAlert: AlertValue? { get set }
    var onComplete: VoidAction { get set }

    func push(to view: any Hashable)
    func pop()
    func popToRootView()
    func presentAlert(title: String, message: String)
}

@Observable
open class Router: Routing {
    public var path: NavigationPath
    public var isPresentingAlert: AlertValue?
    public var onComplete: VoidAction
    
    public init(
        path: NavigationPath = NavigationPath(),
        onComplete: VoidAction
    ) {
        self.path = path
        self.onComplete = onComplete
    }
    
    public func push(to view: any Hashable) {
        path.append(view)
    }

    public func pop() {
        guard path.isEmpty == false else { return }
        path.removeLast()
    }
    
    public func popToRootView() {
        path.removeAll()
    }
    
    public func presentAlert(title: String, message: String) {
        isPresentingAlert = AlertValue(title: title, message: message)
    }
}
