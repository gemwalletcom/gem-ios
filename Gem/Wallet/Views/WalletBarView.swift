import SwiftUI
import Style
import Components
import Primitives

struct WalletBarViewViewModel {
    let name: String
    let image: AssetImage?
    let showChevron: Bool
}

extension WalletBarViewViewModel {
    static func from(wallet: Wallet, showChevron: Bool = true) -> WalletBarViewViewModel {
        let model = WalletViewModel(wallet: wallet)
        return WalletBarViewViewModel(
            name: model.name,
            image: model.assetImage,
            showChevron: showChevron
        )
    }
}

struct WalletBarView: View {
    
    let model: WalletBarViewViewModel
    var action: (() -> Void)?
    
    init(
        model: WalletBarViewViewModel,
        action: (() -> Void)? = nil
    ) {
        self.model = model
        self.action = action
    }
    
    var body: some View {
        Button {
            action?()
        } label: {
            HStack(spacing: 8) {
                if let image = model.image {
                    AssetImageView(assetImage: image, size: 24, overlayImageSize: 10)
                }
                Text(model.name)
                    .foregroundColor(Colors.black)
                    .fontWeight(.medium)
                    .font(.body)
                    .lineLimit(1)
                
                if model.showChevron {
                    Image(systemName: SystemImage.chevronDown)
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

struct WalletBarView_Previews: PreviewProvider {
    static var previews: some View {
        WalletBarView(
            model: WalletBarViewViewModel(
                name: WalletViewModel(wallet: .main).name,
                image: .none,
                showChevron: false
            )
        )
    }
}
