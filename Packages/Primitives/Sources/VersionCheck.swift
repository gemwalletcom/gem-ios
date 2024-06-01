// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct VersionCheck {
    
    public static func isVersionHigher(new: String, current: String) -> Bool {
        let newComponents = new.components(separatedBy: ".").compactMap { Int($0) }
        let currentComponents = current.components(separatedBy: ".").compactMap { Int($0) }
        
        for (newComponent, currentComponent) in zip(newComponents, currentComponents) {
            if newComponent > currentComponent {
                return true
            } else if newComponent < currentComponent {
                return false
            }
        }
        return newComponents.count > currentComponents.count
    }
}
