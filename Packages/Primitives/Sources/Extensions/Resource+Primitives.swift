// Copyright (c). Gem Wallet. All rights reserved.

extension Resource: Identifiable {
    public var id: Self { self }
    public var key: String { rawValue.uppercased() }
}
