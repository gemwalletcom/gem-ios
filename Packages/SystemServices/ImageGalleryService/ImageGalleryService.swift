// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import UIKit
import Photos

public struct ImageGalleryService: Sendable {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - Public methods
    
    public func saveImageFromURL(_ url: URL) async throws(ImageGalleryServiceError) {
        try await checkPermitionToPhotos()
        let data = try await fetchData(from: url)
        let image = try imageFromData(data)
        await saveImageToPhotos(image: image)
    }
    
    // MARK: - Private methods
    
    private func checkPermitionToPhotos() async throws(ImageGalleryServiceError) {
        let permitionStatus = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        switch permitionStatus {
        case .restricted, .denied:
            throw ImageGalleryServiceError.permissionDenied
        case .authorized, .limited, .notDetermined:
            return
        @unknown default:
            return
        }
    }
    
    private func fetchData(from url: URL) async throws(ImageGalleryServiceError) -> Data {
        do {
            let (data, response) = try await session.data(from: url)
            try validateHTTPResponse(response)
            return data
        } catch {
            throw ImageGalleryServiceError.urlSessionError(error)
        }
    }
    
    private func validateHTTPResponse(_ response: URLResponse?) throws(ImageGalleryServiceError) {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ImageGalleryServiceError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw ImageGalleryServiceError.unexpectedStatusCode(httpResponse.statusCode)
        }
    }
    
    private func imageFromData(_ data: Data) throws(ImageGalleryServiceError) -> UIImage {
        guard let image = UIImage(data: data) else {
            throw ImageGalleryServiceError.invalidData
        }
        return image
    }
    
    private func saveImageToPhotos(image: UIImage) async {
        await withCheckedContinuation { continuation in
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            continuation.resume()
        }
    }
}
