import Testing
import Foundation
@testable import FileStore

struct FileStoreTests {
    @Test
    func testStoreAndRetrieveData() async throws {
        let fileStore = FileStore()
        let testKey = FileStorageKey.avatar(walletId: "walletId", avatarId: "testStoreAndRetrieveData")
        let testData = "FileStore!"
        
        try fileStore.store(value: testData, for: testKey)
        let retrievedData: String? = try fileStore.value(for: testKey)

        #expect(retrievedData == testData)
    }

    @Test
    func testRetrieveNonExistentData() async throws {
        let fileStore = FileStore()
        let testKey = FileStorageKey.avatar(walletId: "walletId", avatarId: "testRetrieveNonExistentData")

        let retrievedData: String? = try fileStore.value(for: testKey)

        #expect(retrievedData == nil)
    }

    @Test
    func testRemoveStoredData() async throws {
        let fileStore = FileStore()
        let testKey = FileStorageKey.avatar(walletId: "walletId", avatarId: "testRemoveStoredData")
        let testData = "Temporary Data"
        
        try fileStore.store(value: testData, for: testKey)
        try fileStore.remove(for: testKey)
        let retrievedData: String? = try fileStore.value(for: testKey)

        #expect(retrievedData == nil)
    }

    @Test
    func testOverwriteExistingData() async throws {
        let fileStore = FileStore()
        let testKey = FileStorageKey.avatar(walletId: "walletId", avatarId: "testOverwriteExistingData")
        let originalData = "Original"
        let newData = "New Data"

        try fileStore.store(value: originalData, for: testKey)
        try fileStore.store(value: newData, for: testKey)

        let retrievedData: String? = try fileStore.value(for: testKey)

        #expect(retrievedData == newData)
    }
}
