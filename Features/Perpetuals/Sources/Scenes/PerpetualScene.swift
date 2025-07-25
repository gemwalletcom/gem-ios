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
                        subtitle: position.sizeValueText
                    )
                    
                    ListItemView(
                        title: "Margin",
                        subtitle: position.marginText
                    )
                    
                    if let text = position.liquidationPriceText {
                        ListItemView(
                            title: "Liquidation Price",
                            subtitle: text,
                            subtitleStyle: TextStyle(font: .callout, color: position.liquidationPriceColor),
                            infoAction: { model.onSelectLiquidationPriceInfo() }
                        )
                    }
                    
                    ListItemView(
                        title: "Funding",
                        subtitle: position.fundingText,
                        subtitleStyle: TextStyle(font: .callout, color: position.fundingColor),
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
            
            Section {
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
            } header: {
                Text("Info")
            }
            
            
        }
        .navigationTitle(model.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $model.isPresentingInfoSheet) {
            InfoSheetScene(model: InfoSheetViewModel(type: $0))
        }
    }
}
