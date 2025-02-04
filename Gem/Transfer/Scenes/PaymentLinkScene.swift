// Copyright (c). Gem Wallet. All rights reserved.

import Components
import Localization
import Style
import SwiftUI
import Primitives
import BigInt

struct PaymentLinkScene: View {
    static let iconSize: CGFloat = 64
    let model: PaymentLinkViewModel
    @Binding private var navigationPath: NavigationPath

    init(
        model: PaymentLinkViewModel,
        navigationPath: Binding<NavigationPath>
    ) {
        self.model = model
        _navigationPath = navigationPath
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

            Text("\(model.data.label)")
                .font(.title3)
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
        // FIXME, decode and verify tx
        let transferData = TransferData(
            type: .payment(model.data),
            recipientData: RecipientData(
                recipient: Recipient(name: model.data.label, address: "", memo: nil), amount: nil),
            value: BigInt(0),
            canChangeValue: false
        )
        navigationPath.append(transferData)
    }
}
