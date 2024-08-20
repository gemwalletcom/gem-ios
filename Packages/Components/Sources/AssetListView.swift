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

extension AssetListViewable {
    var isAssetEnabled: Bool {
        switch rightView {
        case .balance,
            .copy: return false
        case .toggle(let value): return value
        }
    }
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

public struct AssetListItemView<PrimaryView: View, SecondaryView: View>: View {
    let imageView: AssetImageView
    let primary: PrimaryView
    let secondary: SecondaryView

    public init(
        imageView: AssetImageView,
        @ViewBuilder primary: () -> PrimaryView,
        @ViewBuilder secondary: () -> SecondaryView
    ) {
        self.imageView = imageView
        self.primary = primary()
        self.secondary = secondary()
    }
    
    public var body: some View {
        HStack {
            imageView
            HStack {
                primary
                Spacer(minLength: Spacing.extraSmall)
                secondary
            }
        }
    }
}

public struct AssetListView: View {
    let model: AssetListViewable
    @State private var toggleValue: Bool

    public init(model: AssetListViewable) {
        self.model = model
        _toggleValue = State(wrappedValue: model.isAssetEnabled)
    }

    public var body: some View {
        AssetListItemView(
            imageView: AssetImageView(assetImage: model.assetImage),
            primary: {
                VStack(alignment: .leading, spacing: Spacing.extraSmall) {
                    HStack(spacing: Spacing.tiny) {
                        Text(model.name)
                            .textStyle(
                                TextStyle(font: .body, color: .primary, fontWeight: .semibold)
                            )
                        if let symbol = model.symbol {
                            Text(symbol)
                                .textStyle(.calloutSecondary)
                        }
                    }

                    switch model.subtitleView {
                    case .price(let price, let priceChangePercentage24h):
                        HStack(spacing: Spacing.extraSmall) {
                            Text(price.text)
                                .textStyle(price.style)
                            Text(priceChangePercentage24h.text)
                                .textStyle(priceChangePercentage24h.style)
                        }
                    case .type(let textValue):
                        Text(textValue.text)
                            .textStyle(textValue.style)
                    case .none:
                        EmptyView()
                    }
                }
            },
            secondary: {
                ZStack {
                    switch model.rightView {
                    case .balance(let balance, let totalFiat):
                        VStack(alignment: .trailing, spacing: Spacing.extraSmall) {
                            Text(balance.text)
                                .textStyle(balance.style)

                            if !totalFiat.text.isEmpty {
                                Text(totalFiat.text)
                                    .textStyle(totalFiat.style)
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
                            padding: Spacing.small,
                            action: {
                                model.action?(.copy)
                            }
                        )
                        .background(Colors.grayVeryLight)
                        .foregroundStyle(Colors.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                    }
                }
            }
        )
        .onChange(of: toggleValue) { _, newValue in
            model.action?(.enabled(newValue))
        }
    }
}

#Preview {
    struct AssetListViewPreviewable: AssetListViewable {
        let name: String
        let symbol: String?
        let assetImage: AssetImage
        let subtitleView: AssetListSubtitleView
        let rightView: AssetListRightView
        var action: ((AssetListAction) -> Void)?
    }

    return List {
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
