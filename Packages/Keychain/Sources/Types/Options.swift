// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

struct Options: @unchecked Sendable {
    var service: String = ""
    var accessibility: Accessibility = .afterFirstUnlock
    var authenticationPolicy: AuthenticationPolicy?
    var synchronizable: Bool = false
    var authenticationContext: AnyObject?
    var attributes = [String: Any]()
}

extension Options {
    func query(ignoringAttributeSynchronizable: Bool = true) -> [String: Any] {
        var query = [String: Any]()

        query[Class] = String(kSecClassGenericPassword)
        if ignoringAttributeSynchronizable {
            query[AttributeSynchronizable] = SynchronizableAny
        } else {
            query[AttributeSynchronizable] = synchronizable ? kCFBooleanTrue : kCFBooleanFalse
        }

        query[AttributeService] = service

        #if !os(watchOS)
        if #available(iOS 9.0, OSX 10.11, *) {
            if authenticationContext != nil {
                query[UseAuthenticationContext] = authenticationContext
            }
        }
        #endif

        return query
    }

    func attributes(key: String?, value: Data) -> ([String: Any], Error?) {
        var attributes: [String: Any]

        if key != nil {
            attributes = query()
            attributes[AttributeAccount] = key
        } else {
            attributes = [String: Any]()
        }

        attributes[ValueData] = value

        if let policy = authenticationPolicy {
            if #available(OSX 10.10, *) {
                var error: Unmanaged<CFError>?
                guard
                    let accessControl = SecAccessControlCreateWithFlags(kCFAllocatorDefault, accessibility.rawValue as CFTypeRef, SecAccessControlCreateFlags(rawValue: CFOptionFlags(policy.rawValue)), &error)
                else {
                    if let error = error?.takeUnretainedValue() {
                        return (attributes, error.error)
                    }

                    return (attributes, Status.unexpectedError)
                }
                attributes[AttributeAccessControl] = accessControl
            } else {
                print("Unavailable 'Touch ID integration' on OS X versions prior to 10.10.")
            }
        } else {
            attributes[AttributeAccessible] = accessibility.rawValue
        }

        attributes[AttributeSynchronizable] = synchronizable ? kCFBooleanTrue : kCFBooleanFalse

        return (attributes, nil)
    }
}
