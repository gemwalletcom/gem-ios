// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

final class SelectAssetSceneNavigationStackRobot: Robot {
    func startManage() -> Self {
        start(scenario: .selectAssetManage)
        
        return self
    }
    
    @discardableResult
    func checkFilterButton() -> Self {
        assert(filterButton, [.exists, .isHittable])
        
        return self
    }
    
    @discardableResult
    func checkPlusButton() -> Self {
        assert(plusButton, [.exists, .isHittable])
        
        return self
    }
}
