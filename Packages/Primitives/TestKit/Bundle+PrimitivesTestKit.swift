// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension Bundle {
    static func decode<T: Decodable>(
        from filename: String,
        withExtension fileExtension: String,
        in bundle: Bundle
    ) throws -> T {
        guard let fileURL = bundle.url(forResource: filename, withExtension: fileExtension) else {
            throw AnyError("Can't find \(filename).\(fileExtension) in \(bundle.bundlePath)")
        }
        
        let fileData = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(T.self, from: fileData)
    }
}
