// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI

extension UIColor {

    public var color: Color {
        Color(self)
    }
    
    public class func dynamicColor(_ light: Color, dark: Color?) -> Color {
        return UIColor {
            switch $0.userInterfaceStyle {
            case .dark:
                return dark?.uiColor ?? light.uiColor
            default:
                return light.uiColor
            }
        }.color
   }
}
