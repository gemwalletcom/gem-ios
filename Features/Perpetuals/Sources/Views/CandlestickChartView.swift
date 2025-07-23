// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Charts
import Style
import Primitives
import PrimitivesComponents

struct CandlestickChartView: View {
    let data: [ChartCandleStick]
    let period: ChartPeriod
    let basePrice: Double?
    
    @State private var selectedCandle: ChartPriceModel? {
        didSet {
            if let selectedCandle, selectedCandle.date != oldValue?.date {
                vibrate()
            }
        }
    }
    
    init(data: [ChartCandleStick], period: ChartPeriod = .day, basePrice: Double? = nil) {
        self.data = data
        self.period = period
        self.basePrice = basePrice ?? data.first?.close
    }
    
    var body: some View {
        let minPrice = data.map { min($0.low, $0.open, $0.close) }.min() ?? 0
        let maxPrice = data.map { max($0.high, $0.open, $0.close) }.max() ?? 1
        let priceRange = maxPrice - minPrice
        let padding = priceRange * 0.02 // Add 2% padding
        
        VStack {
            priceHeader
            chartView(minPrice: minPrice - padding, maxPrice: maxPrice + padding)
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
    
    private func chartView(minPrice: Double, maxPrice: Double) -> some View {
        let dateRange = (data.first?.date ?? Date())...(data.last?.date ?? Date())
        
        return Chart(data, id: \.date) { candle in
                // High-Low line (wick)
                RuleMark(
                    x: .value("Date", candle.date),
                    yStart: .value("Low", candle.low),
                    yEnd: .value("High", candle.high)
                )
                .lineStyle(StrokeStyle(lineWidth: 1))
                .foregroundStyle(candle.close >= candle.open ? Colors.green : Colors.red)
                
                // Open-Close body
                RectangleMark(
                    x: .value("Date", candle.date),
                    yStart: .value("Open", candle.open),
                    yEnd: .value("Close", candle.close),
                    width: .fixed(4)
                )
                .foregroundStyle(candle.close >= candle.open ? Colors.green : Colors.red)
                
                // Selection indicator
                if let selectedCandle,
                   let selectedDate = selectedCandle.date,
                   let selectedCandleData = data.first(where: { abs($0.date.timeIntervalSince(selectedDate)) < 1 }) {
                    PointMark(
                        x: .value("Date", selectedDate),
                        y: .value("Price", selectedCandleData.close)
                    )
                    .symbol {
                        Circle()
                            .strokeBorder(Colors.blue, lineWidth: 2)
                            .background(Circle().foregroundColor(Colors.white))
                            .frame(width: 12)
                    }
                    
                    RuleMark(
                        x: .value("Date", selectedDate)
                    )
                    .foregroundStyle(Colors.blue)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                }
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
                AxisMarks(position: .bottom, values: .automatic(desiredCount: 6)) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        .foregroundStyle(Colors.gray.opacity(0.5))
                }
            }
            .chartYAxis {
                AxisMarks(position: .trailing, values: .automatic(desiredCount: 5)) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        .foregroundStyle(Colors.gray.opacity(0.5))
                    AxisTick(stroke: StrokeStyle(lineWidth: 1))
                        .foregroundStyle(Colors.gray.opacity(0.5))
                    AxisValueLabel()
                        .foregroundStyle(Colors.gray)
                        .font(.caption2)
                }
            }
            .chartXScale(domain: dateRange)
            .chartYScale(domain: minPrice...maxPrice)
    }
    
    private func formatAxisDate(_ date: Date) -> String {
        switch period {
        case .hour:
            return date.formatted(.dateTime.hour().minute())
        case .day:
            return date.formatted(.dateTime.hour(.defaultDigits(amPM: .abbreviated)))
        case .week, .month:
            return date.formatted(.dateTime.month(.abbreviated).day())
        case .year, .all:
            return date.formatted(.dateTime.month(.abbreviated).year(.twoDigits))
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
            currency: "USD"
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
            currency: "USD"
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
