
import Foundation
import SwiftUI

public enum AsyncNFTImagePhase {
    case empty
    case success(Image)
    case failure(Error)

    public var image: Image? {
        if case let .success(img) = self { return img }
        return nil
    }

    public var error: Error? {
        if case let .failure(err) = self { return err }
        return nil
    }
}

public struct CachedAsyncNFTImage<Content>: View where Content: View {
    @Environment(\.displayScale) var displayScale
    @State private var phase: AsyncNFTImagePhase = .empty

    private let urlRequest: URLRequest?
    private let session: URLSession
    private let transaction: Transaction
    private let content: (AsyncNFTImagePhase) -> Content

    public var body: some View {
        content(phase)
            .task(id: urlRequest) {
                await load()
            }
    }

    public init(
        url: URL?,
        urlCache: URLCache = .shared,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (AsyncNFTImagePhase) -> Content
    ) {
        let request = url.map { URLRequest(url: $0) }
        self.init(
            urlRequest: request,
            urlCache: urlCache,
            transaction: transaction,
            content: content
        )
    }

    public init(
        urlRequest: URLRequest?,
        urlCache: URLCache = .shared,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (AsyncNFTImagePhase) -> Content
    ) {
        self.urlRequest = urlRequest
        let config = URLSessionConfiguration.default
        config.urlCache = urlCache
        self.session = URLSession(configuration: config)
        self.transaction = transaction
        self.content = content
    }

    private func load() async {
        guard let urlRequest else {
            withAnimation(transaction.animation) {
                phase = .empty
            }
            return
        }

        if let image = try? cachedImage(from: urlRequest) {
            phase = .success(image)
            return
        }

        do {
            let (data, response, metrics) = try await dataWithMetrics(for: urlRequest)

            if let lastResponse = metrics.transactionMetrics.last?.response {
                let cachedResponse = CachedURLResponse(response: lastResponse, data: data)
                session.configuration.urlCache?.storeCachedResponse(cachedResponse, for: urlRequest)
            }

            let parsedImage = try parseImageOrSVG(from: data, response: response)

            withAnimation(transaction.animation) {
                phase = .success(parsedImage)
            }
        } catch {
            withAnimation(transaction.animation) {
                phase = .failure(error)
            }
        }
    }
}

private extension CachedAsyncNFTImage {
    enum RenderNFTImageError: Error {
        case invalidImage
        case invalidSVG
    }

    func cachedImage(from request: URLRequest) throws -> Image? {
        guard let cache = session.configuration.urlCache,
              let cachedResponse = cache.cachedResponse(for: request) else {
            return nil
        }
        return try parseImageOrSVG(from: cachedResponse.data, response: cachedResponse.response)
    }

    func dataWithMetrics(for request: URLRequest) async throws -> (Data, URLResponse, URLSessionTaskMetrics) {
        let controller = URLSessionTaskController()
        let (data, response) = try await session.data(for: request, delegate: controller)
        guard let metrics = controller.metrics else {
            throw URLError(.unknown)
        }
        return (data, response, metrics)
    }

    func parseImageOrSVG(from data: Data, response: URLResponse) throws -> Image {
        let mimeType = response.mimeType?.lowercased() ?? ""
        if mimeType.contains("svg") || looksLikeSVG(data: data) {
            return try renderSVGToImage(data: data)
        } else {
            return try renderNormalImage(data: data)
        }
    }

    func looksLikeSVG(data: Data) -> Bool {
        guard let sample = String(data: data.prefix(100), encoding: .utf8) else { return false }
        return sample.lowercased().contains("<svg")
    }

    func renderNormalImage(data: Data) throws -> Image {
        guard let uiImage = UIImage(data: data, scale: displayScale) else {
            throw RenderNFTImageError.invalidImage
        }
        return Image(uiImage: uiImage)
    }

    func renderSVGToImage(data: Data) throws -> Image {
        guard let svg = SVG(data) else {
            throw RenderNFTImageError.invalidSVG
        }
        let uiImg = svg.renderedUIImage()
        return Image(uiImage: uiImg)
    }
}

// MARK: - URLSessionTaskController

private final class URLSessionTaskController: NSObject, URLSessionTaskDelegate, @unchecked Sendable {
    var metrics: URLSessionTaskMetrics?

    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        self.metrics = metrics
    }
}
