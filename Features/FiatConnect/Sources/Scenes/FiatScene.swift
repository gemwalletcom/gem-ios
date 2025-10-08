import SwiftUI
import Primitives
import Style
import Components
import GRDBQuery
import Store
import PrimitivesComponents

public struct FiatScene: View {
    @FocusState private var focusedField: Field?
    enum Field: Int, Hashable, Identifiable {
        case amountBuy
        case amountSell
        var id: String { String(rawValue) }
    }

    private var model: FiatSceneViewModel

    public init(model: FiatSceneViewModel) {
        self.model = model
    }

    public var body: some View {
        @Bindable var model = model
        List {
            CurrencyInputValidationView(
                model: $model.inputValidationModel,
                config: model.currencyInputConfig
            )
            .focused($focusedField, equals: model.input.type == .buy ? .amountBuy : .amountSell)
            .padding(.top, .medium)
            .listGroupRowStyle()
            amountSelectorSection
            providerSection
        }
        .safeAreaView {
            StateButton(
                text: model.actionButtonTitle,
                type: .primary(model.state, showProgress: false),
                action: model.onSelectContinue
            )
            .frame(maxWidth: .scene.button.maxWidth)
            .padding(.bottom, .scene.bottom)
        }
        .contentMargins([.top], .zero, for: .scrollContent)
        .frame(maxWidth: .infinity)
        .onChange(of: model.focusField, onChangeFocus)
        .onChange(of: model.input.type, model.onChangeType)
        .onChange(of: model.inputValidationModel.text, model.onChangeAmountText)
        .debounce(
            value: model.input.amount,
            initial: true,
            interval: .none,
            action: model.onChangeAmountValue
        )
        .onAppear {
            focusedField = model.focusField
        }
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
                            model.onSelectTypeAmount()
                        }
                        .font(.subheadline.weight(.semibold))
                        .buttonStyle(model.typeAmountButtonStyle)
                        .if(model.input.type == .buy) {
                            $0.overlay {
                                RandomOverlayView()
                            }
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
            switch model.state {
            case .noData:
                StateEmptyView(title: model.emptyTitle)
            case .loading:
                ListItemLoadingView()
                    .id(UUID())
            case .data:
                if let quote = model.input.quote {
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
                    ListItemView(title: model.rateTitle, subtitle: model.rateValue(for: quote))
                } else {
                    EmptyView()
                }
            case .error(let error):
                ListItemErrorView(errorTitle: model.errorTitle, error: error)
            }
        }
    }
}

// MARK: - Actions

extension FiatScene {
    private func onChangeFocus(_ _: Field?, _ newField: Field?) {
        focusedField = newField
    }
}
