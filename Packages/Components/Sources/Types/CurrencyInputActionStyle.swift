// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUICore

public struct CurrencyInputActionStyle {
    let position: CurrencyInputActionPosition
    let image: Image
    let imageSize: CGFloat = 20
    
    public init(position: CurrencyInputActionPosition, image: Image) {
        self.position = position
        self.image = image
    }
}

public enum CurrencyInputActionPosition {
    case amount
    case secondary
}
