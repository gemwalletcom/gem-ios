// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import UIKit

public extension UIImage {    
    func compress(_ jpegQuality: JPEGQuality) -> Data? {
        jpegData(compressionQuality: jpegQuality.rawValue)
    }
}
