// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import CloudKit

public actor CloudSyncService {
    private let container: CKContainer
    private let database: CKDatabase
    private let transformer: DataTransformable

    public init(
        containerIdentifier: String,
        transformer: DataTransformable
    ) {
        self.container = CKContainer(identifier: containerIdentifier)
        self.database = container.privateCloudDatabase
        self.transformer = transformer
    }

    // MARK: - Account Status

    public func checkAccountStatus() async throws -> CKAccountStatus {
        try await container.accountStatus()
    }

    public func isAvailable() async -> Bool {
        (try? await checkAccountStatus()) == .available
    }

    // MARK: - Save

    public func save<T: CloudSyncable>(_ item: T) async throws {
        try await database.save(try createRecord(for: item))
    }

    public func save<T: CloudSyncable>(_ items: [T]) async throws {
        let records = try items.map { try createRecord(for: $0) }
        _ = try await database.modifyRecords(saving: records, deleting: [])
    }

    // MARK: - Fetch

    public func fetch<T: CloudSyncable>(_ type: T.Type) async throws -> [T] {
        try await fetchAllRecords(recordType: T.recordType).compactMap { _, result in
            switch result {
            case .success(let record): try decodeRecord(record, as: type)
            case .failure: nil
            }
        }
    }

    // MARK: - Delete

    public func delete<T: CloudSyncable>(_ item: T) async throws {
        try await database.deleteRecord(withID: item.recordID)
    }

    public func delete<T: CloudSyncable>(_ items: [T]) async throws {
        _ = try await database.modifyRecords(saving: [], deleting: items.map { $0.recordID })
    }

    public func deleteAll<T: CloudSyncable>(_ type: T.Type) async throws {
        let ids = try await fetchAllRecords(recordType: T.recordType, desiredKeys: []).map { $0.0 }
        guard !ids.isEmpty else { return }
        _ = try await database.modifyRecords(saving: [], deleting: ids)
    }

    // MARK: - Private

    private func createRecord<T: CloudSyncable>(for item: T) throws -> CKRecord {
        let data = try JSONEncoder().encode(item)
        let record = CKRecord(recordType: T.recordType, recordID: item.recordID)
        record.payload = try transformer.transform(data)
        return record
    }

    private func decodeRecord<T: CloudSyncable>(_ record: CKRecord, as type: T.Type) throws -> T {
        guard let data = record.payload else {
            throw CloudSyncError.invalidRecordData
        }
        return try JSONDecoder().decode(type, from: try transformer.restore(data))
    }

    private func fetchAllRecords(
        recordType: String,
        desiredKeys: [CKRecord.FieldKey]? = nil
    ) async throws -> [(CKRecord.ID, Result<CKRecord, any Error>)] {
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        var (allResults, cursor) = try await database.records(matching: query, desiredKeys: desiredKeys)

        while let currentCursor = cursor {
            let (nextResults, nextCursor) = try await database.records(continuingMatchFrom: currentCursor, desiredKeys: desiredKeys)
            allResults.append(contentsOf: nextResults)
            cursor = nextCursor
        }

        return allResults
    }
}

private extension CKRecord {
    var payload: Data? {
        get { self["data"] as? Data }
        set { self["data"] = newValue }
    }
}
