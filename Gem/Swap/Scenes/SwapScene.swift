// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Store
import GRDBQuery
import Components
import Style
import BigInt

struct SwapScene: View {
    
    @Query<AssetRequest> var fromAsset: AssetData
    @Query<AssetRequest> var toAsset: AssetData
    @Query<TransactionsRequest> var tokenApprovals: [TransactionExtended]
    
    @Environment(\.nodeService) private var nodeService
    
    @StateObject var model: SwapViewModel
    @State var transferData: TransferData?
    
    enum Field: Int, Hashable {
        case from, to
    }
    @FocusState private var focusedField: Field?
    
    init(
        model: SwapViewModel
    ) {
        _model = .init(wrappedValue: model)
        _fromAsset = Query(model.fromAssetRequest, in: \.db.dbQueue)
        _toAsset = Query(model.toAssetRequest, in: \.db.dbQueue)
        _tokenApprovals = Query(model.tokenApprovalsRequest, in: \.db.dbQueue)
    }
    
    var body: some View {
        VStack {
            List {
                Section(
                    header: Text(Localized.Swap.youPay),
                    footer: SwapChangeView(fromId: $fromAsset.assetId, toId: $toAsset.assetId)
                        .offset(y: 16)
                        .frame(maxWidth: .infinity)
                ) {
                    SwapTokenView(
                        model: SwapTokenViewModel(model: AssetDataViewModel(assetData: fromAsset, formatter: .medium)),
                        text: $model.fromValue,
                        balanceAction: {
                            model.useFromMax(asset: fromAsset.asset, value: fromAsset.balance.available)
                            focusedField = .none
                        }
                    )
                    .buttonStyle(.borderless)
                    .focused($focusedField, equals: .from)
                }
                
                Section(Localized.Swap.youReceive) {
                    SwapTokenView(
                        model: SwapTokenViewModel(model: AssetDataViewModel(assetData: toAsset, formatter: .medium)),
                        text: $model.toValue,
                        showLoading: model.quoteState.isLoading,
                        disabledTextField: true,
                        balanceAction: {
                            //
                        }
                    )
                    .focused($focusedField, equals: .to)
                }
    
                Section {
                    TransactionsList(tokenApprovals, showSections: false)
                }
            }
            Spacer()
            SwapFooterView(state: model.allowanceState, tokenName: fromAsset.asset.symbol) {
                Task {
                    await self.swap()
                }
            }
            .padding(.bottom, Spacing.scene.bottom)
            .frame(maxWidth: Spacing.scene.button.maxWidth)
        }
        .background(Colors.grayBackground)
        .navigationDestination(for: $transferData) {
            ConfirmTransferScene(
                model: ConfirmTransferViewModel(
                    wallet: model.wallet,
                    keystore: model.keystore,
                    data: $0,
                    service: ChainServiceFactory(nodeProvider: nodeService)
                        .service(for: $0.recipientData.asset.chain),
                    walletService: model.walletService
                )
            )
        }
        .onChange(of: fromAsset) {
            model.resetValues()
            focusedField = .from
            
            Task { await updateAllowance() }
        }
        .onChange(of: model.fromValue) {
            Task {
                model.get_quote(fromAsset: fromAsset.asset, toAsset: toAsset.asset, amount: model.fromValue)
            }
        }
        .onChange(of: tokenApprovals) {
            Task {
                await updateAllowance()
            }
            
            if tokenApprovals.isEmpty {
                focusedField = .from
            }
        }
        .task {
            Task { await updateAllowance() }
            Task { await updateAssets() }
        }
        .onAppear {
            if model.toValue.isEmpty {
                focusedField = .from
            }
        }
        .navigationTitle(model.title)
    }
    
    func swap() async {
        Task {
            guard case .loaded(let allowance) = model.allowanceState else {
                return
            }
            do {
                if allowance {
                    self.transferData = try await model.swap(fromAsset: fromAsset.asset, toAsset: toAsset.asset, amount: model.fromValue)
                } else {
                    let spender = try await SwapService.getSpender(chain: fromAsset.asset.chain, quote: model.quoteTask?.value)
                    self.transferData = try model.getAllowanceData(fromAsset: fromAsset.asset, toAsset: toAsset.asset, spender: spender)
                }
                focusedField = .none
            } catch {
                NSLog("swapAction error: \(error)")
            }
        }
    }
    
    func updateAllowance() async {
        do {
            try await model.updateAllowance(fromAsset: fromAsset.asset)
        } catch {
            NSLog("updateAllowance error: \(error)")
        }
    }
    
    func updateAssets() async {
        do {
            try await model.updateAssets(assetIds: [fromAsset.asset.id, toAsset.asset.id])
        } catch {
            NSLog("updatePrices error: \(error)")
        }
    }
}

//#Preview {
//    SwapScene()
//}
