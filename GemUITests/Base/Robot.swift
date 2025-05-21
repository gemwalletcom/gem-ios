// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import XCUIAutomation
import XCTest

@MainActor
class Robot {

    private static let defaultTimeout: Double = 30

    var app: XCUIApplication

    lazy var navigationBar = app.navigationBars.firstMatch
    lazy var navigationBarButton = navigationBar.buttons.firstMatch
    lazy var navigationBarTitle = navigationBar.otherElements.firstMatch

    init(_ app: XCUIApplication) {
        self.app = app
    }

    @discardableResult
    func start(
        launchEnvironment: UITestLaunchScenario,
        timeout: TimeInterval = Robot.defaultTimeout
    ) -> Self {
        app.setLaunchEnvironment(launchEnvironment)
        app.launch()
        assert(app, [.exists], timeout: timeout)

        return self
    }

    @discardableResult
    func tap(
        _ element: XCUIElement,
        timeout: TimeInterval = Robot.defaultTimeout
    ) -> Self {
        assert(element, [.isHittable], timeout: timeout)
        element.tap()

        return self
    }

    @discardableResult
    func assert(
        _ element: XCUIElement,
        _ predicates: [Predicate],
        timeout: TimeInterval = Robot.defaultTimeout
    ) -> Self {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: predicates.map { $0.format }.joined(separator: " AND ")), object: element)
        guard XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed else {
            XCTFail("[\(self)] Element \(element.description) did not fulfill expectation: \(predicates.map { $0.format })")
            return self
        }

        return self
    }

    @discardableResult
    func checkTitle(
        contains title: String,
        timeout: TimeInterval = Robot.defaultTimeout
    ) -> Self {
        assert(navigationBar, [.isHittable], timeout: timeout)
        assert(navigationBarTitle, [.contains(title)], timeout: timeout)

        return self
    }

    @discardableResult
    func back(
        timeout: TimeInterval = Robot.defaultTimeout
    ) -> Self {
        tap(navigationBarButton, timeout: timeout)

        return self
    }
}
