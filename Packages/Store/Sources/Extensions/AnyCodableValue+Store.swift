// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

extension AnyCodableValue: @retroactive SQLExpressible {}
extension AnyCodableValue: @retroactive StatementBinding {}
extension AnyCodableValue: @retroactive DatabaseValueConvertible {
    public var databaseValue: DatabaseValue {
        guard let data = try? JSONEncoder().encode(self),
              let string = String(data: data, encoding: .utf8) else {
            return .null
        }
        return string.databaseValue
    }

    public static func fromDatabaseValue(_ dbValue: DatabaseValue) -> AnyCodableValue? {
        guard let string = String.fromDatabaseValue(dbValue),
              let data = string.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode(AnyCodableValue.self, from: data)
    }
}
