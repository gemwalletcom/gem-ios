import SwiftUI
import Primitives
import Style
import Components
import GRDBQuery
import Store

public struct FiatScene: View {
    @FocusState private var focusedField: Field?
    enum Field: Int, Hashable, Identifiable {
        case amount
        var id: String { String(rawValue) }
    }

    @Query<AssetRequest>
    private var assetData: AssetData

    @State private var model: FiatSceneViewModel

    public init(model: FiatSceneViewModel) {
        _model = State(initialValue: model)
        _assetData = Query(constant: model.assetRequest)
    }

    public var body: some View {
        VStack {
            List {
                CurrencyInputView(
                    text: $model.amountText,
                    config: model.currencyInputConfig
                )
                .padding(.top, .medium)
                .listGroupRowStyle()
                .focused($focusedField, equals: .amount)

                amountSelectorSection
                providerSection
            }
            .contentMargins([.top], .zero, for: .scrollContent)
            Spacer()
            StateButton(
                text: model.actionButtonTitle,
                viewState: model.state,
                showProgressIndicator: false,
                action: onSelectContinue
            )
            .frame(maxWidth: .scene.button.maxWidth)
        }
        .padding(.bottom, .scene.bottom)
        .background(Colors.grayBackground)
        .frame(maxWidth: .infinity)
        .if(!model.showFiatTypePicker(assetData)) {
            $0.navigationTitle(model.title)
        }
        .toolbar {
            if model.showFiatTypePicker(assetData) {
                ToolbarItem(placement: .principal) {
                    Picker("", selection: $model.input.type) {
                        Text(model.pickerTitle(type: .buy))
                            .tag(FiatTransactionType.buy)
                        Text(model.pickerTitle(type: .sell))
                            .tag(FiatTransactionType.sell)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }
            }
        }
        .onChange(of: model.input.type, onChangeType)
        .onChange(
            of: model.amountText,
            initial: true,
            model.changeAmountText
        )
        .debounce(
            value: model.input.amount,
            interval: .none,
            action: onChangeAmount
        )
        .onAppear {
            focusedField = .amount
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
                balance: model.assetBalance(assetData: assetData),
                secondary: {
                    HStack(spacing: .small + .extraSmall) {
                        ForEach(model.suggestedAmounts, id: \.self) { amount in
                            Button(model.buttonTitle(amount: amount)) {
                                onSelect(amount: amount)
                            }
                            .font(.subheadline.weight(.semibold))
                            .buttonStyle(.amount())
                        }

                        Button(model.typeAmountButtonTitle) {
                            onSelectTypeAmount()
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
            case .loaded(let quotes):
                if let quote = model.input.quote {
                    if quotes.count > 1 {
                        NavigationLink(value: Scenes.FiatProviders()) {
                            ListItemImageView(
                                title: model.providerTitle,
                                subtitle: quote.provider.name,
                                assetImage: model.providerAssetImage(quote.provider)
                            )
                        }
                    } else {
                        ListItemImageView(
                            title: model.providerTitle,
                            subtitle: quote.provider.name,
                            assetImage: model.providerAssetImage(quote.provider)
                        )
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
    private func onSelectContinue() {
        guard let quote = model.input.quote,
              let url = URL(string: quote.redirectUrl) else { return }

        UIApplication.shared.open(url, options: [:])
    }

    private func onSelect(amount: Double) {
        model.select(amount: amount, assetData: assetData)
    }

    private func onSelectTypeAmount() {
        model.selectTypeAmount(assetData: assetData)
    }

    private func onChangeAmount(_ amount: Double) async {
        await model.fetch(for: assetData)
    }

    func onChangeType(_: FiatTransactionType, type: FiatTransactionType) {
        // reset focus on type switch
        focusedField = .none
        focusedField = .amount
        model.selectType(type)
    }
}
