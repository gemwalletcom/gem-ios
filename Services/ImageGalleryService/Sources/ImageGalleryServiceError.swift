// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum ImageGalleryServiceError: Error {
    case wrongURL
    case invalidData
    case invalidResponse
    case unexpectedStatusCode(Int)
    case urlSessionError(Error)
    case permissionDenied
}
