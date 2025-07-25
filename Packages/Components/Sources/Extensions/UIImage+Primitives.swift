// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import UIKit

public extension UIImage {    
    func compress(compressionQuality: CGFloat = 1.0) -> Data? {
        jpegData(compressionQuality: compressionQuality)
    }
}
