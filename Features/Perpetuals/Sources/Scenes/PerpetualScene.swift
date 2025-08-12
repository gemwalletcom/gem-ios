import SwiftUI
import Primitives
import Components
import Style
import PerpetualService
import PrimitivesComponents
import InfoSheet

public struct PerpetualScene: View {
    
    @Bindable var model: PerpetualSceneViewModel
    
    public init(model: PerpetualSceneViewModel) {
        self.model = model
    }
    
    public var body: some View {
        List {
            Section { } header: {
                VStack {
                    VStack {
                        switch model.state {
                        case .noData: StateEmptyView.noData()
                        case .loading: LoadingView()
                        case .data(let data): CandlestickChartView(data: data, period: model.currentPeriod)
                        case .error(let error): StateEmptyView.error(error)
                        }
                    }
                    .frame(height: 320)
                    
                    PeriodSelectorView(selectedPeriod: $model.currentPeriod)
                }
            }
            .cleanListRow()
            
            ForEach(model.positionViewModels) { position in
                Section {
                    ListAssetItemView(
                        model: PerpetualPositionItemViewModel(model: position)
                    )
                    
                    ListItemView(
                        title: position.pnlTitle,
                        subtitle: position.pnlWithPercentText,
                        subtitleStyle: position.pnlTextStyle
                    )
                    
                    ListItemView(
                        title: position.sizeTitle,
                        subtitle: position.sizeValueText
                    )
                    
                    if let text = position.entryPriceText {
                        ListItemView(
                            title: position.entryPriceTitle,
                            subtitle: text
                        )
                    }
                    
                    if let text = position.liquidationPriceText {
                        ListItemView(
                            title: position.liquidationPriceTitle,
                            subtitle: text,
                            subtitleStyle: position.liquidationPriceTextStyle,
                            infoAction: { model.onSelectLiquidationPriceInfo() }
                        )
                    }
                    
                    ListItemView(
                        title: position.marginTitle,
                        subtitle: position.marginText
                    )
                    
                    ListItemView(
                        title: position.fundingPaymentsTitle,
                        subtitle: position.fundingPaymentsText,
                        subtitleStyle: position.fundingPaymentsTextStyle,
                        infoAction: { model.onSelectFundingPaymentsInfo() }
                    )
                } header: {
                    Text(model.positionSectionTitle)
                }
            }
            
            Section {
                if model.hasOpenPosition {
                    Button(model.closePositionTitle, action: model.onClosePosition)
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.red())
                } else {
                    HStack(spacing: Spacing.medium) {
                        Button(model.longButtonTitle, action: model.onOpenLongPosition)
                            .frame(maxWidth: .infinity)
                            .buttonStyle(.green())
                        
                        Button(model.shortButtonTitle, action: model.onOpenShortPosition)
                            .frame(maxWidth: .infinity)
                            .buttonStyle(.red())
                    }
                }
            }
            
            Section(header: Text(model.infoSectionTitle)) {
                ListItemView(
                    title: model.perpetualViewModel.volumeTitle,
                    subtitle: model.perpetualViewModel.volumeText
                )
                
                ListItemView(
                    title: model.perpetualViewModel.openInterestTitle,
                    subtitle: model.perpetualViewModel.openInterestText,
                    infoAction: { model.onSelectOpenInterestInfo() }
                )
                
                ListItemView(
                    title: model.perpetualViewModel.fundingRateTitle,
                    subtitle: model.perpetualViewModel.fundingRateText,
                    infoAction: { model.onSelectFundingRateInfo() }
                )
            }
            
            if !model.transactions.isEmpty {
                Section(header: Text(model.transactionsSectionTitle)) {
                    TransactionsList(
                        explorerService: model.explorerService,
                        model.transactions
                    )
                    .listRowInsets(.assetListRowInsets)
                }
            }
        }
        .navigationTitle(model.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $model.isPresentingInfoSheet) {
            InfoSheetScene(type: $0)
        }
        .refreshable {
            await model.fetch()
        }
        .taskOnce {
            Task {
                await model.fetch()
            }
        }
    }
}
