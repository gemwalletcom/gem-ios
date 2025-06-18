// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension CFError {
    var error: NSError {
        let domain = CFErrorGetDomain(self) as String
        let code = CFErrorGetCode(self)
        let userInfo = CFErrorCopyUserInfo(self) as! [String: Any]

        return NSError(domain: domain, code: code, userInfo: userInfo)
    }
}
