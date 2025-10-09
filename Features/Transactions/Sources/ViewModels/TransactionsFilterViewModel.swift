// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import Localization
import PrimitivesComponents

@Observable
@MainActor
public final class TransactionsFilterViewModel {
    private let wallet: Wallet
    private let type: TransactionsRequestType
    
    public var chainsFilter: ChainsFilterViewModel {
        didSet { request.filters = requestFilters }
    }
    public var transactionTypesFilter: TransactionTypesFilterViewModel {
        didSet { request.filters = requestFilters }
    }
    
    public var request: TransactionsRequest
    
    private static let excludeTransactionTypes: [TransactionType] = [.perpetualOpenPosition, .perpetualClosePosition]
    private let transactionTypes = TransactionType.allCases.filter( { !excludeTransactionTypes.contains($0) })
    
    private let defaultFilters: [TransactionsRequestFilter] = [
        .assetRankGreaterThan(AssetScore.defaultScore),
    ]
    
    var isPresentingChains: Bool = false
    var isPresentingTypes: Bool = false

    public init(
        wallet: Wallet,
        type: TransactionsRequestType
    ) {
        self.wallet = wallet
        self.type = type
        
        self.chainsFilter = ChainsFilterViewModel(chains: wallet.chains)
        self.transactionTypesFilter = TransactionTypesFilterViewModel(types: TransactionType.allCases)
        
        self.request = TransactionsRequest(
            walletId: wallet.id,
            type: type,
            filters: defaultFilters + [.types(transactionTypes.map { $0.rawValue })] // FIX: pass requestFilters for consistency
        )
    }

    public var isAnyFilterSpecified: Bool {
        chainsFilter.isAnySelected || transactionTypesFilter.isAnySelected
    }

    public var title: String { Localized.Filter.title }
    public var clear: String { Localized.Filter.clear }
    public var done: String { Localized.Common.done }

    public var networksModel: NetworkSelectorViewModel {
        NetworkSelectorViewModel(
            state: .data(.plain(chainsFilter.allChains)),
            selectedItems: chainsFilter.selectedChains,
            selectionType: .multiSelection
        )
    }

    public var typesModel: TransactionTypesSelectorViewModel {
        TransactionTypesSelectorViewModel(
            state: .data(.plain(transactionTypesFilter.allTransactionsTypes)),
            selectedItems: transactionTypesFilter.selectedTypes,
            selectionType: .multiSelection
        )
    }
    
    private var requestFilters: [TransactionsRequestFilter] {
        var filters: [TransactionsRequestFilter] = defaultFilters
        
        if !chainsFilter.selectedChains.isEmpty {
            let chainIds = chainsFilter.selectedChains.map { $0.rawValue }
            filters.append(.chains(chainIds))
        }
        
        if !transactionTypesFilter.selectedTypes.isEmpty {
            let typeIds = transactionTypesFilter.requestFilters.map { $0.rawValue }
            filters.append(.types(typeIds))
        } else {
            filters.append(.types(transactionTypes.map { $0.rawValue }))
        }
        
        return filters
    }
}

// MARK: - Actions
extension TransactionsFilterViewModel {
    func onSelectChainsFilter() {
        isPresentingChains = true
    }

    func onSelectTypesFilter() {
        isPresentingTypes = true
    }
}
