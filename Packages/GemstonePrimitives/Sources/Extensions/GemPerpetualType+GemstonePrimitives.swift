import Foundation
import Gemstone
import Primitives

extension GemPerpetualType {
    func map() throws -> PerpetualType {
        switch self {
        case .open(let data): .open(try data.map())
        case .close(let data): .close(try data.map())
        }
    }
}

extension PerpetualType {
    func map() -> GemPerpetualType {
        switch self {
        case .open(let data): .open(data: data.map())
        case .close(let data): .close(data: data.map())
        }
    }
}

extension PerpetualConfirmData {
    func map() -> GemPerpetualConfirmData {
        GemPerpetualConfirmData(
            direction: direction.map(),
            asset: asset.map(),
            assetIndex: assetIndex,
            price: price,
            fiatValue: fiatValue,
            size: size
        )
    }
}

extension PerpetualDirection {
    func map() -> GemPerpetualDirection {
        switch self {
        case .short: .short
        case .long: .long
        }
    }
}
