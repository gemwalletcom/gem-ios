// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Blockchain

// TODO: - move Cache from HTTPClient, this is a copy - probably create separate package with FeeRateService and HTTPClient to use Cache
actor Cache<Key: Hashable & Sendable, Value: Sendable> {
    private var storage: [Key: (value: Value, expiration: Date)] = [:]
    private let ttl: TimeInterval

    public init(ttl: TimeInterval) {
        self.ttl = ttl
    }

    public func set(_ key: Key, value: Value) {
        let expiration = Date().addingTimeInterval(ttl)
        storage[key] = (value, expiration)
    }

    public func get(_ key: Key) -> Value? {
        guard let entry = storage[key] else { return nil }
        if Date() > entry.expiration {
            storage.removeValue(forKey: key)
            return nil
        }
        return entry.value
    }

    public func remove(_ key: Key) {
        storage.removeValue(forKey: key)
    }

    public func clear() {
        storage.removeAll()
    }
}

public protocol FeeRateProviding: Sendable {
    func rates(for type: TransferDataType) async throws -> [FeeRate] // cached
    func refresh(for type: TransferDataType) async throws -> [FeeRate] // bypass
    func invalidate(type: TransferDataType)
    func invalidateAll()
}

public struct FeeRateService: FeeRateProviding {
    private let service: any ChainFeeRateFetchable
    private let cache: Cache<String, [FeeRate]>

    public init(
        service: any ChainFeeRateFetchable,
        ttl: TimeInterval = .zero
    ) {
        self.service = service
        self.cache = Cache(ttl: ttl)
    }

    public func rates(for type: TransferDataType) async throws -> [FeeRate] {
        if let cached = await cache.get(key(type)) { return cached }
        return try await refresh(for: type)
    }

    public func refresh(for type: TransferDataType) async throws -> [FeeRate] {
        let rates = try await service.feeRates(type: type)
        await cache.set(key(type), value: rates)
        return rates
    }

    public func invalidate(type: TransferDataType) {
        Task { await cache.remove(key(type)) }
    }

    public func invalidateAll() {
        Task { await cache.clear() }
    }
}

// MARK: - Private

extension FeeRateService {
    private func key(_ type: TransferDataType) -> String { "\(type.chain.id)_\(type)" }
}
