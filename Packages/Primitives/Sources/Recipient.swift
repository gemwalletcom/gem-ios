import Foundation

public struct Recipient: Codable, Equatable, Hashable, Sendable {
	public let name: String?
	public let address: String
	public let memo: String?

	public init(name: String?, address: String, memo: String?) {
		self.name = name
		self.address = address
		self.memo = memo
	}
}

public enum RecipientAssetType: Codable, Equatable, Hashable, Sendable {
    case asset(Asset)
    case nft(NFTAsset)
}

extension RecipientAssetType: Identifiable {
    public var id: String {
        switch self {
        case .asset(let asset): asset.id.identifier
        case .nft(let asset): asset.id
        }
    }
}

public struct RecipientData: Codable, Equatable, Hashable, Sendable {
    public let recipient: Recipient
    public let amount: String?
    
    public init(
        recipient: Recipient,
        amount: String?
    ) {
        self.recipient = recipient
        self.amount = amount
    }
}
