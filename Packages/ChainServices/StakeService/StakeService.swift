// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives
import ChainService
import GemAPI
import Blockchain

public struct StakeService: StakeServiceable {
    private let store: EarnStore
    private let addressStore: AddressStore
    private let chainServiceFactory: ChainServiceFactory
    private let assetsService: GemAPIStaticService

    public init(
        store: EarnStore,
        addressStore: AddressStore,
        chainServiceFactory: ChainServiceFactory,
        assetsService: GemAPIStaticService = GemAPIStaticService()
    ) {
        self.store = store
        self.addressStore = addressStore
        self.chainServiceFactory = chainServiceFactory
        self.assetsService = assetsService
    }

    public func stakeApr(assetId: AssetId) throws -> Double? {
        try store.getStakeApr(assetId: assetId)
    }

    public func update(walletId: WalletId, chain: Chain, address: String) async throws {
        let validators = try store.getValidators(assetId: chain.assetId)
        if validators.isEmpty {
            try await updateValidators(chain: chain)
            try await updateDelegations(walletId: walletId, chain: chain, address: address)
        } else {
            try await updateDelegations(walletId: walletId, chain: chain, address: address)
            try await updateValidators(chain: chain)
        }
    }

    public func getValidatorsActive(assetId: AssetId) throws -> [DelegationValidator] {
        try store.getValidatorsActive(assetId: assetId)
    }

    public func getValidator(assetId: AssetId, validatorId: String) throws -> DelegationValidator? {
        try store.getValidator(assetId: assetId, validatorId: validatorId)
    }

    public func clearDelegations() throws {
        try store.clear(type: .stake)
    }

    public func clearValidators() throws {
        try store.clearValidators()
    }
}

// MARK: - Private

extension StakeService {
    private func updateValidators(chain: Chain) async throws {
        let apr = try stakeApr(assetId: chain.assetId) ?? 0

        async let getValidators = chainServiceFactory.service(for: chain).getValidators(apr: apr)
        async let getValidatorsList = assetsService.getValidators(chain: chain)

        let (validators, validatorsList) = try await (
            getValidators,
            getValidatorsList.toMap { $0.id }
        )

        let updateValidators = validators.map {
            let name = $0.name.isEmpty ? validatorsList[$0.id]?.name ?? .empty : $0.name
            return DelegationValidator(
                chain: $0.chain,
                id: $0.id,
                name: name,
                isActive: $0.isActive,
                commission: $0.commission,
                apr: $0.apr
            )
        }
        try store.updateValidators(updateValidators)

        let addressNames = updateValidators.map { AddressName(chain: $0.chain, address: $0.id, name: $0.name)}
        try addressStore.addAddressNames(addressNames)
    }

    private func updateDelegations(walletId: WalletId, chain: Chain, address: String) async throws {
        let delegations = try await getDelegations(chain: chain, address: address)
        let existingPositions = try store.getPositions(walletId: walletId, assetId: chain.assetId, type: .stake)
        let existingIds = existingPositions.map { $0.record.id }.asSet()
        let delegationsIds = delegations.map { delegationRecordId(walletId: walletId, delegation: $0, chain: chain) }.asSet()
        let deleteIds = existingIds.subtracting(delegationsIds).asArray()

        let validatorsIds = try store.getValidators(assetId: chain.assetId).map { $0.id }.asSet()
        let delegationsValidatorIds = delegations.map { $0.validatorId }.asSet()
        let missingValidatorIds = delegationsValidatorIds.subtracting(validatorsIds)

        if !missingValidatorIds.isEmpty {
            debugLog("missingValidatorIds \(missingValidatorIds)")
        }

        let updatePositions = delegations
            .filter { validatorsIds.contains($0.validatorId) }
            .map { delegation in
                let validatorRecordId = DelegationValidator.recordId(chain: chain, validatorId: delegation.validatorId)
                return delegation.toEarnPosition(walletId: walletId.id, validatorRecordId: validatorRecordId)
            }

        try store.updateAndDelete(walletId: walletId, positions: updatePositions, deleteIds: deleteIds)
    }

    private func getDelegations(chain: Chain, address: String) async throws -> [DelegationBase] {
        let service = chainServiceFactory.service(for: chain)
        return try await service.getStakeDelegations(address: address)
    }

    private func delegationRecordId(walletId: WalletId, delegation: DelegationBase, chain: Chain) -> String {
        let validatorRecordId = DelegationValidator.recordId(chain: chain, validatorId: delegation.validatorId)
        return delegation.toEarnPosition(walletId: walletId.id, validatorRecordId: validatorRecordId).record.id
    }
}
