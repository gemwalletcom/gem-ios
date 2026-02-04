import SwiftUI
import Style
import Components
import Primitives

public struct WalletBarView: View {
    private let model: WalletBarViewViewModel
    private let action: (() -> Void)?

    public init(
        model: WalletBarViewViewModel,
        action: (() -> Void)? = nil
    ) {
        self.model = model
        self.action = action
    }

    public var body: some View {
        Button {
            action?()
        } label: {
            HStack(spacing: .small) {
                AssetImageView(assetImage: model.image, size: .large)
                
                Text(model.name)
                    .foregroundStyle(Colors.black)
                    .fontWeight(.medium)
                    .font(.body)
                    .lineLimit(1)

                Images.System.chevronDown
                    .resizable()
                    .frame(width: 11, height: 6)
                    .fontWeight(.medium)
                    .foregroundStyle(Colors.gray)
            }
            .padding(.small)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("walletBar")
    }
}

// MARK: - Previews

#Preview {
    WalletBarView(
        model: WalletBarViewViewModel(
            name: WalletViewModel(
                wallet: .init(
                    id: "",
                    externalId: nil,
                    name: "Wallet #1",
                    index: 1,
                    type: .multicoin,
                    accounts: [.init(chain: .algorand, address: "", derivationPath: "", extendedPublicKey: "")],
                    order: 1,
                    isPinned: true,
                    imageUrl: nil,
                    source: .create
                )
            ).name,
            image: AssetImage(imageURL: .none, placeholder: .none, chainPlaceholder: .none)
        )
    )
}
