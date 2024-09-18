import SwiftUI
import Style

public struct ListAssetItemView: View {
    let model: ListAssetItemViewable
    @State private var toggleValue: Bool

    public init(model: ListAssetItemViewable) {
        self.model = model
        _toggleValue = State(wrappedValue: model.isAssetEnabled)
    }

    public var body: some View {
        ListItemFlexibleView(
            left: { AssetImageView(assetImage: model.assetImage) },
            primary: { primaryContent },
            secondary: { secondaryContent }
        )
        .onChange(of: toggleValue) { _, newValue in
            model.action?(.enabled(newValue))
        }
    }
}

// MARK: - Components

extension ListAssetItemView {
    @ViewBuilder
    private var primaryContent: some View {
        VStack(alignment: .leading, spacing: Spacing.tiny) {
            headerView
            subtitleView
        }
    }

    private var headerView: some View {
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
    }

    @ViewBuilder
    private var subtitleView: some View {
        switch model.subtitleView {
        case .price(let price, let priceChangePercentage24h):
            if !price.text.isEmpty {
                HStack(spacing: Spacing.extraSmall) {
                    Text(price.text)
                        .textStyle(price.style)
                    Text(priceChangePercentage24h.text)
                        .textStyle(priceChangePercentage24h.style)
                }
            }
        case .type(let textValue):
            Text(textValue.text)
                .textStyle(textValue.style)
        case .none:
            EmptyView()
        }
    }

    @ViewBuilder
    private var secondaryContent: some View {
        switch model.rightView {
        case .balance(let balance, let totalFiat):
            balanceView(balance: balance, totalFiat: totalFiat)
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
        case .none:
            EmptyView()
        }
    }

    private func balanceView(balance: TextValue, totalFiat: TextValue) -> some View {
        VStack(alignment: .trailing, spacing: Spacing.tiny) {
            Text(balance.text)
                .textStyle(balance.style)
            if !totalFiat.text.isEmpty {
                Text(totalFiat.text)
                    .textStyle(totalFiat.style)
            }
        }
        .lineLimit(1)
    }
}

// MARK: - Previews

#Preview {
    struct AssetListViewPreviewable: ListAssetItemViewable {
        let name: String
        let symbol: String?
        let assetImage: AssetImage
        let subtitleView: ListAssetItemSubtitleView
        let rightView: ListAssetItemRightView
        var action: ((ListAssetItemAction) -> Void)?
    }

    return List {
        ListAssetItemView(
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
