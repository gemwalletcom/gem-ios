// Copyright (c). Gem Wallet. All rights reserved.

import CAtomics

public final class NumberIncrementer<T: FixedWidthInteger>: @unchecked Sendable {
    private var storage: atomic_u64_t

    public init(_ initialValue: T) {
        precondition(MemoryLayout<T>.size == 8, "Only 64-bit Int/UInt are supported")
        storage = atomic_u64_t()
        // Bitcast T -> UInt64 (two's-complement preserved for signed types)
        atomic_u64_init(&storage, UInt64(truncatingIfNeeded: initialValue))
    }

    @discardableResult
    public func next() -> T {
        let prevBits = atomic_u64_fetch_add(&storage, 1)
        return T(truncatingIfNeeded: prevBits)
    }

    public func current() -> T {
        let bits = atomic_u64_load(&storage)
        return T(truncatingIfNeeded: bits)
    }
}
