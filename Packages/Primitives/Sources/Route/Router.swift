// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI

public protocol Routing: AnyObject {
    associatedtype Destination
    var path: NavigationPath { get set }
    
    var isPresentingAlert: AlertValue? { get set }
    var isPresentingSheet: IdentifiableWrapper? { get set }
    var isPresentingUrl: URL? { get set }
    
    var onFinishFlow: VoidAction { get set }

    func push(to view: Destination)
    func pop()
    func popToRootView()
    func presentAlert(title: String, message: String)
    func presenting(_ view: any Identifiable)
}

@Observable
public final class Router<T: Hashable>: Routing {
    public typealias Destination = T
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
    
    public func push(to view: Destination) {
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
