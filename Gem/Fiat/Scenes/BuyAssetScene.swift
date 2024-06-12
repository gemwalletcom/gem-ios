import SwiftUI
import Primitives
import Style
import Components

struct BuyAssetScene: View {
    @StateObject var model: BuyAssetViewModel

    var body: some View {
        VStack {
            List {
                amountSelectorSection
                providerSection
            }
            Spacer()
            StatefullButton(
                text: Localized.Common.continue,
                viewState: model.state,
                action: openBuyUrl
            )
            .disabled(model.shouldDisalbeContinueButton)
            .frame(maxWidth: Spacing.scene.button.maxWidth)
        }
        .padding(.bottom, Spacing.scene.bottom)
        .background(Colors.grayBackground)
        .frame(maxWidth: .infinity)
        .navigationTitle(model.title)
        .task {
            await onTask()
        }
        .navigationDestination(for: Scenes.FiatProviders.self) {_ in
            FiatProvidersScene(
                model: FiatProvidersViewModel(
                    buyAssetInput: model.input,
                    asset: model.asset,
                    selectQuote: onSelectQuote(_:)
                )
            )
        }
    }
}

// MARK: - UI Components

extension BuyAssetScene {
    private var amountSelectorSection: some View {
        Section {

        } header: {
            amountSelectorView
                .padding(.top, 20)
        }
        .textCase(nil)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets())
    }

    @ViewBuilder
    private var providerSection: some View {
        Section {
            if !model.state.isLoading {
                providerView
            }
        } header: {
            VStack {
                if model.state.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private var providerView: some View {
        switch model.state {
        case .noData:
            Text(Localized.Buy.noResults)
                .multilineTextAlignment(.center)
        case .loading:
            EmptyView()
        case .loaded:
            if let quote = model.input.quote {
                if model.input.quotes.count > 1 {
                    NavigationLink(value: Scenes.FiatProviders()) {
                        ListItemView(title: Localized.Common.provider, subtitle: quote.provider.name)
                    }
                } else {
                    ListItemView(title: Localized.Common.provider, subtitle: quote.provider.name)
                }
                ListItemView(title: Localized.Buy.rate, subtitle: model.rateText(for: quote))
            } else {
                EmptyView()
            }
        case .error(let error):
            Text(error.localizedDescription)
                .multilineTextAlignment(.center)
        }
    }

    @ViewBuilder
    private var amountSelectorView: some View {
        VStack(alignment: .center) {
            AmountView(
                title: "$\(Int(model.amount))",
                subtitle: model.cryptoAmountText(for: model.input.quote)
            )

            ZStack(alignment: .center) {
                Grid(alignment: .center) {
                    ForEach(model.amounts, id: \.self) { amounts in
                        GridRow(alignment: .center) {
                            ForEach(amounts, id: \.self) { amount in
                                VStack(alignment: .center) {
                                    Button("$\(Int(amount))") {
                                        onSelectNew(amount: amount)
                                    }
                                    .buttonStyle(.blue(paddingHorizontal: 12, paddingVertical: 12))
                                    .font(.callout)
                                }
                            }
                        }
                        .padding(.all, 4)
                    }
                }
            }
            .padding(.top, 8)
        }
    }
}

// MARK: - Actions

extension BuyAssetScene {
    private func onTask() async {
        guard model.input.quote == nil else { return }
        await getQuotesAsync(amount: model.amount)
    }

    private func onSelectContinue() {
        openBuyUrl()
    }

    private func onSelectNew(amount: Double) {
        getQuotes(amount: amount)
    }

    private func onSelectQuote(_ quote: FiatQuote) {
        model.input.quote = quote
    }
}

// MARK: - Effects

extension BuyAssetScene {
    private func getQuotes(amount: Double) {
        Task {
            await getQuotesAsync(amount: amount)
        }
    }

    private func getQuotesAsync(amount: Double) async {
        await model.getQuotes(for: model.asset, amount: amount)
    }

    private func openBuyUrl() {
        guard let quote = model.input.quote,
              let url = URL(string: quote.redirectUrl) else { return }

        // TODO: - use new @Environment(\.openURL) var openURL, insead use UIKit UIApplication
        UIApplication.shared.open(url, options: [:])
    }
}

// MARK: - Previews

#Preview {
    @StateObject var model = BuyAssetViewModel(assetAddress: .init(asset: .main, address: .empty), input: .default)

    return NavigationStack {
        BuyAssetScene(model: model)
            .navigationBarTitleDisplayMode(.inline)
    }
}
