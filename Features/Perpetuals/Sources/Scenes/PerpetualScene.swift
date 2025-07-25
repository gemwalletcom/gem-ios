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
                        .padding(.horizontal, Spacing.medium)
                        .padding(.top, Spacing.medium)
                }
            }
            .cleanListRow()
            
            ForEach(model.positionViewModels) { position in
                Section {
                    ListAssetItemView(model: position)
                        .listRowInsets(.assetListRowInsets)
                    
                    ListItemView(
                        title: "Size",
                        subtitle: position.positionViewModel.sizeValueText
                    )
                    
                    ListItemView(
                        title: "Margin",
                        subtitle: position.positionViewModel.marginText
                    )
                    
                    if let text = position.positionViewModel.liquidationPriceText {
                        ListItemView(
                            title: "Liquidation Price",
                            subtitle: text,
                            subtitleStyle: TextStyle(font: .callout, color: position.positionViewModel.liquidationPriceColor),
                            infoAction: { model.onSelectLiquidationPriceInfo() }
                        )
                    }
                    
                    ListItemView(
                        title: "Funding Payments",
                        subtitle: position.positionViewModel.fundingPaymentsText,
                        subtitleStyle: TextStyle(font: .callout, color: position.positionViewModel.fundingPaymentsColor),
                        infoAction: { model.onSelectFundingPaymentsInfo() }
                    )
                } header: {
                    Text("Position")
                }
            }
            
            Section {
                if model.hasOpenPosition {
                    Button("Close Position", action: model.onClosePosition)
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.red())
                } else {
                    HStack(spacing: Spacing.medium) {
                        Button("Long", action: model.onOpenLongPosition)
                            .frame(maxWidth: .infinity)
                            .buttonStyle(.green())
                        
                        Button("Short", action: model.onOpenShortPosition)
                            .frame(maxWidth: .infinity)
                            .buttonStyle(.red())
                    }
                }
            }
            
            Section(header: Text("Info")) {
                ListItemView(
                    title: "24h Volume",
                    subtitle: model.perpetualViewModel.volumeText
                )
                
                ListItemView(
                    title: "Open Interest",
                    subtitle: model.perpetualViewModel.openInterestText,
                    infoAction: { model.onSelectOpenInterestInfo() }
                )
                
                ListItemView(
                    title: "Funding Rate",
                    subtitle: model.perpetualViewModel.fundingRateText,
                    infoAction: { model.onSelectFundingRateInfo() }
                )
            }
            
            
        }
        .navigationTitle(model.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $model.isPresentingInfoSheet) {
            InfoSheetScene(model: InfoSheetViewModel(type: $0))
        }
    }
}
