import SwiftUI
import Primitives
import Style
import Components
import GRDBQuery
import Store
import PrimitivesComponents

public struct FiatScene: View {
    @State private var model: FiatSceneViewModel

    public init(model: FiatSceneViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        List {
            CurrencyInputValidationView(
                model: $model.inputValidationModel,
                config: model.currencyInputConfig
            )
            .padding(.top, .medium)
            .listGroupRowStyle()
            amountSelectorSection
            providerSection
        }
        .safeAreaView {
            StateButton(
                text: model.actionButtonTitle,
                type: .primary(model.actionButtonState, showProgress: true),
                action: model.onSelectContinue
            )
            .frame(maxWidth: .scene.button.maxWidth)
            .padding(.bottom, .scene.bottom)
        }
        .contentMargins([.top], .zero, for: .scrollContent)
        .frame(maxWidth: .infinity)
        .onChange(of: model.type, model.onChangeType)
        .onChange(of: model.inputValidationModel.text, model.onChangeAmountText)
        .task(id: model.fetchTrigger) {
            await model.performFetch()
        }
        .alertSheet($model.isPresentingAlertMessage)
    }
}

// MARK: - UI Components

extension FiatScene {
    private var amountSelectorSection: some View {
        Section {
            AssetBalanceView(
                image: model.assetImage,
                title: model.assetTitle,
                balance: model.assetBalance,
                secondary: {
                    HStack(spacing: .small + .extraSmall) {
                        ForEach(model.suggestedAmounts, id: \.self) { amount in
                            Button(model.buttonTitle(amount: amount)) {
                                model.onSelect(amount: amount)
                            }
                            .font(.subheadline.weight(.semibold))
                            .buttonStyle(.amount())
                        }

                        Button(model.typeAmountButtonTitle) {
                            model.onSelectRandomAmount()
                        }
                        .font(.subheadline.weight(.semibold))
                        .buttonStyle(.listEmpty())
                        .overlay {
                            RandomOverlayView()
                        }
                    }
                    .fixedSize()
                }
            )
        }
    }

    @ViewBuilder
    private var providerSection: some View {
        Section {
            switch model.quotesState {
            case .noData:
                StateEmptyView(title: model.emptyTitle)
            case .loading:
                ListItemLoadingView()
                    .id(UUID())
            case .data:
                if let quote = model.selectedQuote {
                    let view = ListItemImageView(
                        title: model.providerTitle,
                        subtitle: quote.provider.name,
                        assetImage: model.providerAssetImage(quote.provider)
                    )
                    if model.allowSelectProvider {
                        NavigationCustomLink(
                            with: view,
                            action: model.onSelectFiatProviders
                        )
                    } else {
                        view
                    }
                    ListItemView(title: model.rateTitle, subtitle: model.rateValue)
                } else {
                    EmptyView()
                }
            case .error(let error):
                ListItemErrorView(errorTitle: model.errorTitle, error: error)
            }
        }
    }
}
