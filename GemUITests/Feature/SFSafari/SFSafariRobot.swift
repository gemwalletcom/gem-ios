// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

final class SFSafariRobot: Robot {
    private lazy var safari = app.webViews.firstMatch
    
    @discardableResult
    func checkWebView() -> Self {
        assert(safari, [.exists])
        
        return self
    }

    @discardableResult
    func closeSafari() -> Self {
        tap(doneButton)

        return self
    }
}
