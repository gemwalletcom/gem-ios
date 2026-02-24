import Foundation

public enum RecipientType: Codable, Equatable, Hashable, Sendable {
    case domain(NameProvider)
}

public struct Recipient: Codable, Equatable, Hashable, Sendable {
	public let name: String?
	public let address: String
	public let memo: String?
	public let type: RecipientType?

	public init(name: String?, address: String, memo: String?, type: RecipientType? = nil) {
		self.name = name
		self.address = address
		self.memo = memo
		self.type = type
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
