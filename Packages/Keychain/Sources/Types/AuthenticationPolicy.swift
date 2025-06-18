// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct AuthenticationPolicy: OptionSet, Sendable {
    /**
     User presence policy using Touch ID or Passcode. Touch ID does not
     have to be available or enrolled. Item is still accessible by Touch ID
     even if fingers are added or removed.
     */
    @available(iOS 8.0, OSX 10.10, watchOS 2.0, tvOS 8.0, *)
    public static let userPresence = AuthenticationPolicy(rawValue: 1 << 0)

    /**
     Constraint: Touch ID (any finger) or Face ID. Touch ID or Face ID must be available. With Touch ID
     at least one finger must be enrolled. With Face ID user has to be enrolled. Item is still accessible by Touch ID even
     if fingers are added or removed. Item is still accessible by Face ID if user is re-enrolled.
     */
    @available(iOS 11.3, OSX 10.13.4, watchOS 4.3, tvOS 11.3, *)
    public static let biometryAny = AuthenticationPolicy(rawValue: 1 << 1)

    /**
     Deprecated, please use biometryAny instead.
     */
    @available(iOS, introduced: 9.0, deprecated: 11.3, renamed: "biometryAny")
    @available(OSX, introduced: 10.12.1, deprecated: 10.13.4, renamed: "biometryAny")
    @available(watchOS, introduced: 2.0, deprecated: 4.3, renamed: "biometryAny")
    @available(tvOS, introduced: 9.0, deprecated: 11.3, renamed: "biometryAny")
    public static let touchIDAny = AuthenticationPolicy(rawValue: 1 << 1)

    /**
     Constraint: Touch ID from the set of currently enrolled fingers. Touch ID must be available and at least one finger must
     be enrolled. When fingers are added or removed, the item is invalidated. When Face ID is re-enrolled this item is invalidated.
     */
    @available(iOS 11.3, OSX 10.13, watchOS 4.3, tvOS 11.3, *)
    public static let biometryCurrentSet = AuthenticationPolicy(rawValue: 1 << 3)

    /**
     Deprecated, please use biometryCurrentSet instead.
     */
    @available(iOS, introduced: 9.0, deprecated: 11.3, renamed: "biometryCurrentSet")
    @available(OSX, introduced: 10.12.1, deprecated: 10.13.4, renamed: "biometryCurrentSet")
    @available(watchOS, introduced: 2.0, deprecated: 4.3, renamed: "biometryCurrentSet")
    @available(tvOS, introduced: 9.0, deprecated: 11.3, renamed: "biometryCurrentSet")
    public static let touchIDCurrentSet = AuthenticationPolicy(rawValue: 1 << 3)

    /**
     Constraint: Device passcode
     */
    @available(iOS 9.0, OSX 10.11, watchOS 2.0, tvOS 9.0, *)
    public static let devicePasscode = AuthenticationPolicy(rawValue: 1 << 4)

    /**
     Constraint: Watch
     */
    @available(iOS, unavailable)
    @available(OSX 10.15, *)
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    public static let watch = AuthenticationPolicy(rawValue: 1 << 5)

    /**
     Constraint logic operation: when using more than one constraint,
     at least one of them must be satisfied.
     */
    @available(iOS 9.0, OSX 10.12.1, watchOS 2.0, tvOS 9.0, *)
    public static let or = AuthenticationPolicy(rawValue: 1 << 14)

    /**
     Constraint logic operation: when using more than one constraint,
     all must be satisfied.
     */
    @available(iOS 9.0, OSX 10.12.1, watchOS 2.0, tvOS 9.0, *)
    public static let and = AuthenticationPolicy(rawValue: 1 << 15)

    /**
     Create access control for private key operations (i.e. sign operation)
     */
    @available(iOS 9.0, OSX 10.12.1, watchOS 2.0, tvOS 9.0, *)
    public static let privateKeyUsage = AuthenticationPolicy(rawValue: 1 << 30)

    /**
     Security: Application provided password for data encryption key generation.
     This is not a constraint but additional item encryption mechanism.
     */
    @available(iOS 9.0, OSX 10.12.1, watchOS 2.0, tvOS 9.0, *)
    public static let applicationPassword = AuthenticationPolicy(rawValue: 1 << 31)

    #if swift(>=2.3)
    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    #else
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    #endif
}
