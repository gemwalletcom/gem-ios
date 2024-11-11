import SwiftUI
import Primitives
import Style
import Components
import FiatConnect

struct FiatScene: View {
    @State private var model: FiatViewModel
    @FocusState private var focusedField: Field?

    enum Field: Int, Hashable, Identifiable {
        case amount
        var id: String { String(rawValue) }
    }

    init(model: FiatViewModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        VStack {
            List {
                CurrencyInputView(
                    text: $model.amountText,
                    currencySymbol: model.currencySymbol,
                    currencyPosition: model.currencyPosition,
                    secondaryText: model.cryptoAmountValue,
                    keyboardType: model.keyboardType
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
            value: $model.input.amount,
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
            HStack(spacing: Spacing.small) {
                AssetImageView(assetImage: model.assetImage)

                Text(model.asset.symbol)
                    .textStyle(.headline.weight(.semibold))

                Spacer()

                HStack(spacing: Spacing.medium) {
                    ForEach(model.suggestedAmounts, id: \.self) { amount in
                        Button(model.buttonTitle(amount: amount)) {
                            onSelect(amount: amount)
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Colors.black)
                        .padding(.all, Spacing.small)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundStyle(Colors.grayVeryLight)
                        )
                        .buttonStyle(.plain)
                    }

                    Button(model.typeAmountButtonTitle) {
                        onSelectTypeAmount()
                    }
                    .font(.subheadline.weight(.semibold))
                    .padding(.all, Spacing.small)
                    .background {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundStyle(Colors.grayVeryLight)

                            if model.isBuy {
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(hex: "#2A32FF"),
                                                Color(hex: "#6CB8FF"),
                                                Color(hex: "#F213F6"),
                                                Color(hex: "FFF963")
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 3
                                    )
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
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
        await model.fetch()
    }

    private func onSelectContinue() {
        guard let quote = model.input.quote,
              let url = URL(string: quote.redirectUrl) else { return }

        UIApplication.shared.open(url, options: [:])
    }

    private func onSelect(amount: Double) {
        model.select(amount: amount)
    }

    private func onSelectTypeAmount() {
        model.selectTypeAmount()
    }

    private func onSelectQuote(_ quote: FiatQuote) {
        model.input.quote = quote
    }

    private func onChangeAmount(_ amount: Double) async {
        await model.fetch()
    }
}

// MARK: - Previews

#Preview {
    @Previewable @State var model = FiatViewModel(
        assetAddress: .init(asset: .main, address: .empty),
        input: FiatInput(type: .buy, amount: 50, maxAmount: .zero)
    )
    NavigationStack {
        FiatScene(model: model)
            .navigationBarTitleDisplayMode(.inline)
    }
}
