import SwiftUI
import AvatarToolkit
import Style
import Components
import Primitives
import PrimitivesComponents

struct WalletBarViewViewModel {
    let name: String
    var avatarViewModel: AvatarViewModel
    let showChevron: Bool
}

//extension WalletBarViewViewModel {
//    static func from(wallet: Wallet, showChevron: Bool = true) -> WalletBarViewViewModel {
//        WalletBarViewViewModel(
//            name: WalletViewModel(wallet: wallet).name,
//            avatarViewModel: AvatarViewModel(wallet: wallet, allowEditing: false),
//            showChevron: showChevron
//        )
//    }
//}

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
                } else {
                    AvatarView(model: model.avatarViewModel, size: 24)
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

struct WalletBarView_Previews: PreviewProvider {
    static var previews: some View {
        WalletBarView(
            model: WalletBarViewViewModel(
                name: WalletViewModel(wallet: .main).name,
                avatarViewModel: AvatarViewModel(
                    wallet: .makeView(
                        name: .empty,
                        chain: .ethereum,
                        address: .empty
                    ),
                    allowEditing: false
                ),
                showChevron: false
            )
        )
    }
}
