// Copyright (c). Gem Wallet. All rights reserved.

#pragma once
#include <stdatomic.h>
#include <stdint.h>

typedef struct { _Atomic uint64_t v; } atomic_u64_t;

static inline void atomic_u64_init(atomic_u64_t *a, uint64_t x) {
    atomic_init(&a->v, x);
}
static inline uint64_t atomic_u64_load(const atomic_u64_t *a) {
    return atomic_load_explicit(&a->v, memory_order_seq_cst);
}
static inline uint64_t atomic_u64_fetch_add(atomic_u64_t *a, uint64_t d) {
    return atomic_fetch_add_explicit(&a->v, d, memory_order_seq_cst);
}
