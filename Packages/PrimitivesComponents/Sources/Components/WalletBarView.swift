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
            HStack(spacing: Spacing.small) {
                AssetImageView(assetImage: model.image, size: Spacing.large, overlayImageSize: Sizing.image.tiny)
                
                Text(model.name)
                    .foregroundColor(Colors.black)
                    .fontWeight(.medium)
                    .font(.body)
                    .lineLimit(1)

                Images.System.chevronDown
                    .resizable()
                    .frame(width: 11, height: 6)
                    .fontWeight(.medium)
                    .foregroundColor(Colors.gray)
            }
            .padding(.horizontal, Spacing.tiny)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview {
    WalletBarView(
        model: WalletBarViewViewModel(
            name: WalletViewModel(
                wallet: .init(
                    id: "",
                    name: "Wallet #1",
                    index: 1,
                    type: .multicoin,
                    accounts: [.init(chain: .algorand, address: "", derivationPath: "", extendedPublicKey: "")],
                    order: 1,
                    isPinned: true,
                    imageUrl: nil
                )
            ).name,
            image: AssetImage(imageURL: .none, placeholder: .none, chainPlaceholder: .none)
        )
    )
}
