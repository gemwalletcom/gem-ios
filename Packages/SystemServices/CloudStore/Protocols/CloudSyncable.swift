// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import CloudKit

public protocol CloudSyncable: Identifiable, Codable, Sendable where ID == String {
    static var recordType: String { get }
}

extension CloudSyncable {
    public static var recordType: String {
        String(describing: Self.self)
    }

    var recordID: CKRecord.ID {
        CKRecord.ID(recordName: id)
    }
}
