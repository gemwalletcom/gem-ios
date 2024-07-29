// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public protocol QRScannerResourcesProviding {
    var selectFromPhotos: String { get }
    var openSettings: String { get }
    var tryAgain: String { get }

    var dismissSystemImage: String { get }
    var gallerySystemImage: String { get }
}
