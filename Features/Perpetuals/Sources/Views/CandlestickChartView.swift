// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Charts
import Style
import Primitives
import PrimitivesComponents

private struct ChartKey {
    static let date = "Date"
    static let low = "Low"
    static let high = "High"
    static let open = "Open"
    static let close = "Close"
    static let price = "Price"
}

struct CandlestickChartView: View {
    private let data: [ChartCandleStick]
    private let period: ChartPeriod
    private let basePrice: Double?
    private let lineModels: [ChartLineViewModel]

    @State private var selectedCandle: ChartPriceModel? {
        didSet {
            if let selectedCandle, selectedCandle.date != oldValue?.date {
                vibrate()
            }
        }
    }

    init(
        data: [ChartCandleStick],
        period: ChartPeriod = .day,
        basePrice: Double? = nil,
        lineModels: [ChartLineViewModel] = []
    ) {
        self.data = data
        self.period = period
        self.basePrice = basePrice ?? data.first?.close
        self.lineModels = lineModels
    }
    
    var body: some View {
        VStack {
            priceHeader
            chartView(bounds: ChartBounds(candles: data, lines: lineModels))
        }
    }
    
    private var priceHeader: some View {
        VStack {
            if let selectedCandle {
                ChartPriceView.from(model: selectedCandle)
            } else if let currentPrice = currentPriceModel {
                ChartPriceView.from(model: currentPrice)
            }
        }
        .padding(.top, Spacing.small)
        .padding(.bottom, Spacing.tiny)
    }
    
    private func chartView(bounds: ChartBounds) -> some View {
        let dateRange = (data.first?.date ?? Date())...(data.last?.date ?? Date())

        return Chart {
            candlestickMarks
            linesMarks(bounds)
            selectionMarks
        }
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if let candle = findCandle(location: value.location, proxy: proxy, geometry: geometry) {
                                    selectedCandle = createPriceModel(for: candle)
                                }
                            }
                            .onEnded { _ in
                                selectedCandle = nil
                            }
                    )
            }
        }
        .chartXAxis {
            AxisMarks(position: .bottom, values: .automatic(desiredCount: 6)) { _ in
                AxisGridLine(stroke: ChartGridStyle.strokeStyle)
                    .foregroundStyle(ChartGridStyle.color)
            }
        }
        .chartYAxis {
            AxisMarks(position: .trailing, values: .automatic(desiredCount: 5)) { _ in
                AxisGridLine(stroke: ChartGridStyle.strokeStyle)
                    .foregroundStyle(ChartGridStyle.color)
                AxisTick(stroke: StrokeStyle(lineWidth: ChartGridStyle.lineWidth))
                    .foregroundStyle(ChartGridStyle.color)
                AxisValueLabel()
                    .foregroundStyle(Colors.gray)
                    .font(.caption2)
            }
        }
        .chartXScale(domain: dateRange)
        .chartYScale(domain: bounds.minPrice...bounds.maxPrice)
    }

    @ChartContentBuilder
    private var candlestickMarks: some ChartContent {
        ForEach(data, id: \.date) { candle in
            RuleMark(
                x: .value(ChartKey.date, candle.date),
                yStart: .value(ChartKey.low, candle.low),
                yEnd: .value(ChartKey.high, candle.high)
            )
            .lineStyle(StrokeStyle(lineWidth: 1))
            .foregroundStyle(candle.close >= candle.open ? Colors.green : Colors.red)

            RectangleMark(
                x: .value(ChartKey.date, candle.date),
                yStart: .value(ChartKey.open, candle.open),
                yEnd: .value(ChartKey.close, candle.close),
                width: .fixed(4)
            )
            .foregroundStyle(candle.close >= candle.open ? Colors.green : Colors.red)
        }
    }

    @ChartContentBuilder
    private func linesMarks(_ bounds: ChartBounds) -> some ChartContent {
        ForEach(bounds.visibleLines) { line in
            RuleMark(y: .value(ChartKey.price, line.price))
                .foregroundStyle(line.color.opacity(0.6))
                .lineStyle(line.lineStyle)
        }

        ForEach(Array(bounds.visibleLines.enumerated()), id: \.element.id) { index, line in
            RuleMark(y: .value(ChartKey.price, line.price))
                .foregroundStyle(.clear)
                .annotation(position: .overlay, alignment: .leading, spacing: 0) {
                    Text(line.label)
                        .font(.system(size: .space10, weight: .semibold))
                        .foregroundStyle(Colors.whiteSolid)
                        .padding(.tiny)
                        .background(line.color)
                        .clipShape(RoundedRectangle(cornerRadius: .tiny))
                        .offset(x: labelXOffset(for: index, in: bounds))
                }
        }
    }

    private func labelXOffset(for index: Int, in bounds: ChartBounds) -> CGFloat {
        guard index > 0 else { return 0 }
        let threshold = (bounds.maxPrice - bounds.minPrice) * 0.06
        let lines = bounds.visibleLines
        let space = 115.0
        return (1...index).reduce(0.0) { offset, idx in
            abs(lines[idx].price - lines[idx - 1].price) < threshold ? offset + space : offset
        }
    }

    @ChartContentBuilder
    private var selectionMarks: some ChartContent {
        if let selectedCandle,
           let selectedDate = selectedCandle.date,
           let selectedCandleData = data.first(where: { abs($0.date.timeIntervalSince(selectedDate)) < 1 }) {
            PointMark(
                x: .value(ChartKey.date, selectedDate),
                y: .value(ChartKey.price, selectedCandleData.close)
            )
            .symbol {
                Circle()
                    .strokeBorder(Colors.blue, lineWidth: 2)
                    .background(Circle().foregroundColor(Colors.white))
                    .frame(width: 12)
            }

            RuleMark(x: .value(ChartKey.date, selectedDate))
                .foregroundStyle(Colors.blue)
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
        }
    }
    
    private var currentPriceModel: ChartPriceModel? {
        guard let lastCandle = data.last,
              let base = basePrice else { return nil }
        
        let priceChange = lastCandle.close - base
        let priceChangePercentage = (priceChange / base) * 100
        
        return ChartPriceModel(
            period: period,
            date: nil,
            price: lastCandle.close,
            priceChange: priceChange,
            priceChangePercentage: priceChangePercentage,
            currency: .default
        )
    }

    private func createPriceModel(for candle: ChartCandleStick) -> ChartPriceModel {
        let base = basePrice ?? data.first?.close ?? candle.close
        let priceChange = candle.close - base
        let priceChangePercentage = (priceChange / base) * 100

        return ChartPriceModel(
            period: period,
            date: candle.date,
            price: candle.close,
            priceChange: priceChange,
            priceChangePercentage: priceChangePercentage,
            currency: .default
        )
    }
    
    private func findCandle(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> ChartCandleStick? {
        guard let plotFrame = proxy.plotFrame else { return nil }
        
        let relativeXPosition = location.x - geometry[plotFrame].origin.x
        
        if let date = proxy.value(atX: relativeXPosition) as Date? {
            // Find the closest candle
            var minDistance: TimeInterval = .infinity
            var closestCandle: ChartCandleStick?
            
            for candle in data {
                let distance = abs(candle.date.timeIntervalSince(date))
                if distance < minDistance {
                    minDistance = distance
                    closestCandle = candle
                }
            }
            
            return closestCandle
        }
        
        return nil
    }
    
    private func vibrate() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
