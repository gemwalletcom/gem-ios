import SwiftUI
import Style

public enum AssetListRightView {
    case balance(balance: TextValue, totalFiat: TextValue)
    case toggle(Bool)
    case copy
}

public enum AssetListSubtitleView {
    case price(price: TextValue, priceChangePercentage24h: TextValue)
    case type(TextValue)
    case none
}

public enum AssetListAction {
    case enabled(Bool)
    case copy
}

public protocol AssetListViewable {
    var name: String { get }
    var symbol: String? { get }

    var assetImage: AssetImage { get }

    var subtitleView: AssetListSubtitleView { get }
    var rightView: AssetListRightView { get }
    
    var action: ((AssetListAction) -> Void)? { get set }
}

public struct AssetImage {
    public let type: String
    public let imageURL: URL?
    public let placeholder: Image?
    public let chainPlaceholder: Image?
    
    public init(type: String, imageURL: URL?, placeholder: Image?, chainPlaceholder: Image?) {
        self.type = type
        self.imageURL = imageURL
        self.placeholder = placeholder
        self.chainPlaceholder = chainPlaceholder
    }
    
    public static func resourceImage(image: String) -> AssetImage {
        return AssetImage(
            type: "",
            imageURL: .none,
            placeholder: Image(image),
            chainPlaceholder: .none
        )
    }
}

extension AssetListViewable {
    var isAssetEnabled: Bool {
        switch rightView {
        case .balance,
            .copy: return false
        case .toggle(let value): return value
        }
    }
}

public struct AssetListItemView: View {
    
    let imageView: AssetImageView
    let primary: AnyView
    let secondary: AnyView
        
    public init(
        @ViewBuilder imageView: () -> AssetImageView,
        @ViewBuilder primary: () -> AnyView,
        @ViewBuilder secondary: () -> AnyView
    ) {
        self.imageView = imageView()
        self.primary = primary()
        self.secondary = secondary()
    }
    
    public var body: some View {
        HStack {
            imageView
            HStack {
                primary
                Spacer(minLength: 2)
                secondary
            }
        }
    }
}

public struct AssetListView: View {
    
    let model: AssetListViewable
    @State public  var toggleValue: Bool
    
    public init(model: AssetListViewable) {
        self.model = model
        _toggleValue = State(wrappedValue: model.isAssetEnabled)
    }
    
    public var body: some View {
        AssetListItemView {
            AssetImageView(
                assetImage: model.assetImage
            )
        } primary: {
            AnyView(
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(model.name)
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                        if let symbol = model.symbol {
                            Text(symbol)
                                .font(.callout)
                                .fontWeight(.regular)
                                .foregroundColor(.secondary)
                        }
                    }
                    switch model.subtitleView {
                    case .type(let value):
                        Text(value.text)
                            .font(.system(size: 13))
                            .fontWeight(.regular)
                            .font(value.style.font)
                            .foregroundColor(value.style.color)
                    case .price(let price, let priceChangePercentage24h):
                        if !price.text.isEmpty {
                            HStack(spacing: 2) {
                                Text(price.text)
                                    .font(price.style.font)
                                    .foregroundColor(price.style.color)
                                Text(priceChangePercentage24h.text)
                                    .font(priceChangePercentage24h.style.font)
                                    .foregroundColor(priceChangePercentage24h.style.color)
                            }
                            .lineLimit(1)
                        }
                    case .none:
                        EmptyView()
                    }
                }
            )
        } secondary: {
            AnyView(
                ZStack {
                    switch model.rightView {
                    case .balance(let balance, let totalFiat):
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(balance.text)
                                .font(balance.style.font)
                                .foregroundColor(balance.style.color)
                                
                            if !totalFiat.text.isEmpty {
                                Text(totalFiat.text)
                                    .font(totalFiat.style.font)
                                    .foregroundColor(totalFiat.style.color)
                            }
                        }
                        .lineLimit(1)
                    case .toggle:
                        Toggle("", isOn: $toggleValue)
                            .labelsHidden()
                            .toggleStyle(AppToggleStyle())
                    case .copy:
                        ListButton(
                            image: Image(systemName: SystemImage.copy),
                            padding: 10,
                            action: {
                                model.action?(.copy)
                            }
                        )
                        .background(Colors.grayVeryLight)
                        .foregroundColor(Colors.gray)
                        .cornerRadius(24)
                    }
                }
            )
        }
        .onChange(of: toggleValue) { _, newValue in
            model.action?(.enabled(newValue))
        }
    }
}

struct AssetListView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            AssetListView(
                model: AssetListViewPreviewable(
                    name: "Bitcoin",
                    symbol: "BTC",
                    assetImage: AssetImage(
                        type: "ERC20",
                        imageURL: URL(string: "https://assets.gemwallet.com/blockchains/bitcoin/info/logo.png")!,
                        placeholder: .none,
                        chainPlaceholder: .none
                    ),
                    subtitleView: .none,
                    rightView: .balance(
                        balance: TextValue(text: "test", style: TextStyle(font: .title, color: .accentColor)), 
                        totalFiat: TextValue(text: "test2", style: TextStyle(font: .title, color: .accentColor))
                    )
                )
            )
        }
    }
}

struct AssetListViewPreviewable: AssetListViewable {
    let name: String
    let symbol: String?
    let assetImage: AssetImage
    let subtitleView: AssetListSubtitleView
    let rightView: AssetListRightView
    var action: ((AssetListAction) -> Void)?
}
