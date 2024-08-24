// Copyright (c). Gem Wallet. All rights reserved.

import QRScanner
import Style

struct QRScanResources: QRScannerResources {
    var selectFromPhotos: String { Localized.Library.selectFromPhotoLibrary }
    var openSettings: String { Localized.Common.openSettings }
    var tryAgain: String { Localized.Common.tryAgain }

    var dismissSystemImage: String { SystemImage.chevronDown }
    var gallerySystemImage: String { SystemImage.gallery }
}
