// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public protocol QRScannerTextProviding {
    var errorNotSupportedTitle: String { get }
    var errorNotSupported: String { get }

    var errorPermissionsNotGrantedTitle: String { get }
    var errorPermissionsNotGranted: String { get }

    var errorDecodingTitle: String { get }
    var errorDecoding: String { get }

    var errorUnexpectedTitle: String { get }
    var errorUnexpected: String { get }

    var selectFromPhotos: String { get }
    var openSettings: String { get }
    var retry: String { get }
}

public struct QRScannerTextProvider: QRScannerTextProviding {
    public init() {}

    public var errorNotSupportedTitle: String { "Not Supported" }
    public var errorNotSupported: String { "This device does not support QR code scanning. You can only select QR code image from photos" }

    public var errorPermissionsNotGrantedTitle: String { "Permissions Not Granted" }
    public var errorPermissionsNotGranted: String { "Camera permissions are not granted. Please enable camera access in settings to scan QR codes." }

    public var errorDecodingTitle: String { "Decoding Error" }
    public var errorDecoding: String { "Failed to decode the QR code. Please try again with a different QR code." }

    public var errorUnexpectedTitle: String { "Unexpected Error" }
    public var errorUnexpected: String { "An unexpected error occurred. Please try again." }

    public var selectFromPhotos: String { "Select from photos" }
    public var openSettings: String { "Open settings" }
    public var retry: String { "Retry" }
}
