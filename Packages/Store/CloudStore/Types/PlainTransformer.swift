// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct PlainTransformer: DataTransformable {
    public init() {}

    public func transform(_ data: Data) throws -> Data { data }
    public func restore(_ data: Data) throws -> Data { data }
}
