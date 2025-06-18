// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

/** Class Key Constant */
let Class = String(kSecClass)

/** Attribute Key Constants */
let AttributeAccessible = String(kSecAttrAccessible)

@available(iOS 8.0, OSX 10.10, *)
let AttributeAccessControl = String(kSecAttrAccessControl)

let AttributeSynchronizable = String(kSecAttrSynchronizable)
let AttributeAccount = String(kSecAttrAccount)
let AttributeService = String(kSecAttrService)

let SynchronizableAny = String(kSecAttrSynchronizableAny) //

/** Search Constants */
let MatchLimit = String(kSecMatchLimit)
let MatchLimitOne = String(kSecMatchLimitOne) //

/** Return Type Key Constants */
let ReturnData = String(kSecReturnData)

/** Value Type Key Constants */
let ValueData = String(kSecValueData)

/** Other Constants */

@available(iOS 9.0, OSX 10.11, watchOS 2.0, tvOS 9.0, *)
let UseAuthenticationContext = String(kSecUseAuthenticationContext)
