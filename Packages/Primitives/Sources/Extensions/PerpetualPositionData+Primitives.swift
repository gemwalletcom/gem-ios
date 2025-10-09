import Foundation

extension PerpetualPositionData: Identifiable {
    public var id: String {
        perpetual.id
    }
    
    public var perpetualData: PerpetualData {
        PerpetualData(perpetual: perpetual, asset: asset, metadata: PerpetualMetadata(isPinned: false))
    }
}
