import SwiftUI
import Primitives
import Style
import Components
import FiatConnect
import GRDBQuery
import Store

struct FiatScene: View {
    @FocusState private var focusedField: Field?
    enum Field: Int, Hashable, Identifiable {
        case amount
        var id: String { String(rawValue) }
    }

    @Query<AssetRequest>
    private var assetData: AssetData

    @State private var model: FiatSceneViewModel

    init(model: FiatSceneViewModel) {
        _model = State(initialValue: model)
        _assetData = Query(constant: model.assetRequest)
    }

    var body: some View {
        VStack {
            List {
                CurrencyInputView(
                    text: $model.amountText,
                    config: model.currencyInputConfig
                )
                .padding(.top, Spacing.medium)
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
            .frame(maxWidth: Spacing.scene.button.maxWidth)
        }
        .padding(.bottom, Spacing.scene.bottom)
        .background(Colors.grayBackground)
        .frame(maxWidth: .infinity)
        .navigationTitle(model.title)
        .debounce(
            value: model.input.amount,
            interval: .none,
            action: onChangeAmount
        )
        .task {
            await onTask()
        }
        .onAppear {
            focusedField = .amount
        }
        .onChange(of: model.input.amount) { _, _ in
            focusedField = .amount
        }
        .navigationDestination(for: Scenes.FiatProviders.self) { _ in
            FiatProvidersScene(
                model: FiatProvidersViewModel(
                    type: model.input.type,
                    asset: model.asset,
                    quotes: model.state.value ?? [],
                    selectQuote: onSelectQuote(_:),
                    formatter: CurrencyFormatter.currency()
                )
            )
        }
    }
}

// MARK: - UI Components

extension FiatScene {
    private var amountSelectorSection: some View {
        Section {
            ListItemFlexibleView(
                left: {
                    AssetImageView(assetImage: model.assetImage)
                },
                primary: {
                    VStack(alignment: .leading, spacing: Spacing.tiny) {
                        Text(model.assetTitle)
                            .textStyle(.headline.weight(.semibold))
                        Text(model.assetBalance(assetData: assetData))
                            .textStyle(TextStyle(font: .callout, color: Colors.gray, fontWeight: .medium))
                    }
                },
                secondary: {
                    HStack(spacing: Spacing.small + Spacing.extraSmall) {
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
                            ListItemView(title: model.providerTitle, subtitle: quote.provider.name)
                        }
                    } else {
                        ListItemView(title: model.providerTitle, subtitle: quote.provider.name)
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
    private func onTask() async {
        guard model.input.quote == nil else { return }
        await model.fetch(for: assetData)
    }

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

    private func onSelectQuote(_ quote: FiatQuote) {
        model.input.quote = quote
    }

    private func onChangeAmount(_ amount: Double) async {
        await model.fetch(for: assetData)
    }
}

// MARK: - Previews

#Preview {
    @Previewable @State var model = FiatSceneViewModel(
        assetAddress: .init(asset: .main, address: .empty),
        walletId: .zero,
        type: .buy
    )
    NavigationStack {
        FiatScene(model: model)
            .navigationBarTitleDisplayMode(.inline)
    }
}
