// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components
import Localization

struct PaymentLinkScene: View {
    static let iconSize: CGFloat = 64
    let model: PaymentLinkViewModel

    init(model: PaymentLinkViewModel) {
        self.model = model
    }

    var body: some View {
        VStack(spacing: 10) {
            AsyncImage(url: URL(string: model.data.logo)) { phase in
                switch phase {
                case .empty:
                    ProgressView() // Loading indicator
                case .success(let image):
                    image.resizable()
                        .scaledToFit()
                        .frame(width: Self.iconSize, height: Self.iconSize)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                case .failure:
                    Images.Chains.solana
                        .resizable()
                        .scaledToFit()
                        .frame(width: Self.iconSize, height: Self.iconSize)
                @unknown default:
                    EmptyView()
                }
            }

            Text("Amount: \(model.data.label) SOL")
                .font(.title2)
                .bold()
                .foregroundColor(.primary)

            Spacer()
            Button(Localized.Common.continue, action: next)
                .frame(maxWidth: Spacing.scene.button.maxWidth)
                .buttonStyle(.blue())
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 5)
    }

    func next() {

    }
}


#if DEBUG
struct PaymentLinkScene_Previews: PreviewProvider {
    static var previews: some View {
        PaymentLinkScene(
            model: PaymentLinkViewModel(
                data: PaymentLinkData(
                    label: "1.23",
                    logo: "",
                    chain: .solana,
                    transaction: ""
                )
            )
        )
    }
}
#endif
