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
                if let image = model.image {
                    AssetImageView(assetImage: image, size: 24, overlayImageSize: 10)
                }
                Text(model.name)
                    .foregroundColor(Colors.black)
                    .fontWeight(.medium)
                    .font(.body)
                    .lineLimit(1)

                if model.showChevron {
                    Images.System.chevronDown
                        .resizable()
                        .frame(width: 11, height: 6)
                        .fontWeight(.medium)
                        .foregroundColor(Colors.gray)
                }
            }
            .padding(.horizontal, 4)
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
                    isPinned: true
                )
            ).name,
            image: .none,
            showChevron: false
        )
    )
}
