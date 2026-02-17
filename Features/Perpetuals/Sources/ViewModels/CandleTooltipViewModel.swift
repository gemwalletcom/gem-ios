// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Formatters
import Style
import Components

struct CandleTooltipViewModel {
    struct StyleDefaults {
        static let label = TextStyle(font: .system(size: .space8), color: Colors.secondaryText, fontWeight: .medium)
        static let value = TextStyle(font: .caption2, color: Colors.black, fontWeight: .semibold)
        static let small = TextStyle(font: .system(size: .space8), color: Colors.black, fontWeight: .medium)
        static let rangePrice = TextStyle(font: .system(size: .space10), color: Colors.black, fontWeight: .semibold)
    }

    private let candle: ChartCandleStick
    private let formatter: CurrencyFormatter
    private static let volumeFormatter = CurrencyFormatter(type: .abbreviated, currencyCode: Currency.usd.rawValue)

    init(candle: ChartCandleStick, formatter: CurrencyFormatter) {
        self.candle = candle
        self.formatter = formatter
    }

    var openTitle: TextValue { TextValue(text: "Open", style: StyleDefaults.label) }
    var openValue: TextValue { TextValue(text: formatter.string(double: candle.open), style: StyleDefaults.value) }

    var closeTitle: TextValue { TextValue(text: "Close", style: StyleDefaults.label) }
    var closeValue: TextValue {
        TextValue(
            text: formatter.string(double: candle.close),
            style: TextStyle(font: .caption2, color: PriceChangeColor.color(for: candle.close - candle.open), fontWeight: .semibold)
        )
    }

    var volumeTitle: TextValue { TextValue(text: "Volume", style: StyleDefaults.label) }
    var volumeValue: TextValue { TextValue(text: Self.volumeFormatter.string(candle.volume * candle.close), style: StyleDefaults.small) }

    var rangeBar: RangeBarViewModel {
        let closePosition: Double = {
            let range = candle.high - candle.low
            return range > 0 ? (candle.close - candle.low) / range : 0.5
        }()
        return RangeBarViewModel(
            lowTitle: TextValue(text: "Low", style: TextStyle(font: .system(size: .space8), color: Colors.red, fontWeight: .medium)),
            highTitle: TextValue(text: "High", style: TextStyle(font: .system(size: .space8), color: Colors.green, fontWeight: .medium)),
            lowValue: TextValue(text: formatter.string(double: candle.low), style: StyleDefaults.rangePrice),
            highValue: TextValue(text: formatter.string(double: candle.high), style: StyleDefaults.rangePrice),
            closePosition: closePosition
        )
    }
}
