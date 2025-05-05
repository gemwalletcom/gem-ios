// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI

public protocol Routing: AnyObject {
    var path: NavigationPath { get set }
    
    var isPresentingAlert: AlertValue? { get set }
    var isPresentingSheet: IdentifiableWrapper? { get set }
    var isPresentingUrl: URL? { get set }
    
    var onFinishFlow: VoidAction { get set }

    func push(to view: any Hashable)
    func pop()
    func popToRootView()
    func presentAlert(title: String, message: String)
    func presenting(_ view: any Identifiable)
}

@Observable
open class Router: Routing {
    public var path: NavigationPath
    
    public var isPresentingAlert: AlertValue?
    public var isPresentingSheet: IdentifiableWrapper?
    public var isPresentingUrl: URL?
    
    public var onFinishFlow: VoidAction
    
    public init(
        path: NavigationPath = NavigationPath(),
        onFinishFlow: VoidAction = nil
    ) {
        self.path = path
        self.onFinishFlow = onFinishFlow
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
    
    public func presenting(_ view: any Identifiable) {
        isPresentingSheet = IdentifiableWrapper(value: view)
    }
}
