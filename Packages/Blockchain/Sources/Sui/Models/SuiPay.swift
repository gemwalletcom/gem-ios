/*
 Generated by typeshare 1.11.0
 */

import Foundation

public struct SuiAddStakeRequest: Codable {
	public let senderAddress: String
	public let validatorAddress: String
	public let coins: [String]
	public let amount: String
	public let gasBudget: String

	public init(senderAddress: String, validatorAddress: String, coins: [String], amount: String, gasBudget: String) {
		self.senderAddress = senderAddress
		self.validatorAddress = validatorAddress
		self.coins = coins
		self.amount = amount
		self.gasBudget = gasBudget
	}
}

public struct SuiBatchRequest: Codable {
	public let senderAddress: String
	public let gasBudget: String

	public init(senderAddress: String, gasBudget: String) {
		self.senderAddress = senderAddress
		self.gasBudget = gasBudget
	}
}

public struct SuiBroadcastTransaction: Codable {
	public let digest: String

	public init(digest: String) {
		self.digest = digest
	}
}

public struct SuiCoinMetadata: Codable {
	public let decimals: Int32
	public let name: String
	public let symbol: String

	public init(decimals: Int32, name: String, symbol: String) {
		self.decimals = decimals
		self.name = name
		self.symbol = symbol
	}
}

public struct SuiMoveCallRequest: Codable {
	public let senderAddress: String
	public let objectId: String
	public let module: String
	public let function: String
	public let arguments: [String]
	public let gasBudget: String

	public init(senderAddress: String, objectId: String, module: String, function: String, arguments: [String], gasBudget: String) {
		self.senderAddress = senderAddress
		self.objectId = objectId
		self.module = module
		self.function = function
		self.arguments = arguments
		self.gasBudget = gasBudget
	}
}

public struct SuiPay: Codable {
	public let txBytes: String

	public init(txBytes: String) {
		self.txBytes = txBytes
	}
}

public struct SuiPayRequest: Codable {
	public let senderAddress: String
	public let recipientAddress: String
	public let coins: [String]
	public let gas: String?
	public let amount: String
	public let gasBudget: String

	public init(senderAddress: String, recipientAddress: String, coins: [String], gas: String?, amount: String, gasBudget: String) {
		self.senderAddress = senderAddress
		self.recipientAddress = recipientAddress
		self.coins = coins
		self.gas = gas
		self.amount = amount
		self.gasBudget = gasBudget
	}
}

public struct SuiSplitCoinRequest: Codable {
	public let senderAddress: String
	public let coin: String
	public let splitAmounts: [String]
	public let gasBudget: String

	public init(senderAddress: String, coin: String, splitAmounts: [String], gasBudget: String) {
		self.senderAddress = senderAddress
		self.coin = coin
		self.splitAmounts = splitAmounts
		self.gasBudget = gasBudget
	}
}

public struct SuiStake: Codable {
	public let stakedSuiId: String
	public let status: String
	public let principal: String
	public let stakeRequestEpoch: String
	public let stakeActiveEpoch: String
	public let estimatedReward: String?

	public init(stakedSuiId: String, status: String, principal: String, stakeRequestEpoch: String, stakeActiveEpoch: String, estimatedReward: String?) {
		self.stakedSuiId = stakedSuiId
		self.status = status
		self.principal = principal
		self.stakeRequestEpoch = stakeRequestEpoch
		self.stakeActiveEpoch = stakeActiveEpoch
		self.estimatedReward = estimatedReward
	}
}

public struct SuiStakeDelegation: Codable {
	public let validatorAddress: String
	public let stakingPool: String
	public let stakes: [SuiStake]

	public init(validatorAddress: String, stakingPool: String, stakes: [SuiStake]) {
		self.validatorAddress = validatorAddress
		self.stakingPool = stakingPool
		self.stakes = stakes
	}
}

public struct SuiSystemState: Codable {
	public let epoch: String
	public let epochStartTimestampMs: String
	public let epochDurationMs: String

	public init(epoch: String, epochStartTimestampMs: String, epochDurationMs: String) {
		self.epoch = epoch
		self.epochStartTimestampMs = epochStartTimestampMs
		self.epochDurationMs = epochDurationMs
	}
}

public struct SuiUnstakeRequest: Codable {
	public let senderAddress: String
	public let delegationId: String
	public let gasBudget: String

	public init(senderAddress: String, delegationId: String, gasBudget: String) {
		self.senderAddress = senderAddress
		self.delegationId = delegationId
		self.gasBudget = gasBudget
	}
}

public struct SuiValidator: Codable {
	public let address: String
	public let apy: Double

	public init(address: String, apy: Double) {
		self.address = address
		self.apy = apy
	}
}

public struct SuiValidators: Codable {
	public let apys: [SuiValidator]

	public init(apys: [SuiValidator]) {
		self.apys = apys
	}
}
