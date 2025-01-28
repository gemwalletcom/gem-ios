// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import UIKit

public struct ImageSaverService: Sendable {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func saveImageFromURL(_ url: URL) async throws {
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(
                domain: "AsyncImageSaverService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid response from url"]
            )
        }
        
        guard let image = UIImage(data: data) else {
            throw NSError(
                domain: "AsyncImageSaverService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid image data"]
            )
        }
        
        await saveImageToPhotos(image: image)
    }
    
    private func saveImageToPhotos(image: UIImage) async {
        await withCheckedContinuation { continuation in
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            continuation.resume()
        }
    }
}
