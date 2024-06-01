import SwiftUI
import Primitives
import Style
import Components

struct BuyAssetScene: View {
    
    @StateObject var model: BuyAssetViewModel

    var body: some View {
        VStack {
            List {
                Section { } header: {
                    VStack(alignment: .center) {
                        AmountView(
                            title: "$\(Int(model.amount))",
                            subtitle: model.cryptoAmountText(quote: model.quote)
                        )
                        
                        ZStack(alignment: .center) {
                            Grid(alignment: .center) {
                                ForEach(model.amounts, id: \.self) { amounts in
                                    GridRow(alignment: .center) {
                                        ForEach(amounts, id: \.self) { amount in
                                            VStack(alignment: .center) {
                                                Button("$\(amount)") {
                                                    Task {
                                                        await buy(amount)
                                                    }
                                                }
                                                .buttonStyle(BlueButton(paddingHorizontal: 12, paddingVertical: 12))
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
                    .padding(.top, 20)
                }
                .frame(maxWidth: .infinity)
                .textCase(nil)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                
                Section {
                    if let quote = model.quote {
                        if model.quotes.count > 1 {
                            NavigationLink(value: Scenes.FiatProviders()) {
                                ListItemView(title: Localized.Common.provider, subtitle: quote.provider.name)
                            }
                        } else {
                            ListItemView(title: Localized.Common.provider, subtitle: quote.provider.name)
                        }
                        ListItemView(title: Localized.Buy.rate, subtitle: model.rateText(quote: quote))
                    } else if let quoteError = model.quoteError {
                        Text(quoteError.localizedDescription)
                            .multilineTextAlignment(.center)
                    } else if model.quoteLoading == false {
                        Text(Localized.Buy.noResults)
                            .multilineTextAlignment(.center)
                    }
                } header: {
                    VStack {
                        if model.quoteLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            Spacer()
            
            Button(Localized.Common.continue, action: {
                buyNext()
            })
            .disabled(model.quote == nil)
            .padding(.bottom, Spacing.scene.bottom)
            .frame(maxWidth: Spacing.scene.button.maxWidth)
            .buttonStyle(BlueButton())
        }
        .padding(.bottom, Spacing.scene.bottom)
        .background(Colors.grayBackground)
        .navigationTitle(model.title)
        .task {
            guard model.quote == nil else {
                return
            }
            await model.getQuotes(asset: model.asset, amount: Double(model.defaultaAmount))
        }
        .navigationDestination(for: Scenes.FiatProviders.self) {_ in
            FiatProvidersScene(
                model: FiatProvidersViewModel(
                    currentQuote: model.quote!,
                    asset: model.asset,
                    quotes: model.quotes,
                    selectQuote: {
                        model.quote = $0
                    }
                )
            )
        }
        .frame(maxWidth: .infinity)
    }
    
    func buy(_ amount: Int) async {
        await model.getQuotes(asset: model.asset, amount: Double(amount))
    }
    
    func buyNext() {
        guard
            let quote = model.quote,
            let url = URL(string: quote.redirectUrl) else { return }
        
        UIApplication.shared.open(url, options: [:])
    }
}

//struct BuyAssetScene_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            BuyAssetScene(model: BuyAssetViewModel(assetAddress: <#T##AssetAddress#>))
//        }.navigationBarTitleDisplayMode(.inline)
//    }
//}
