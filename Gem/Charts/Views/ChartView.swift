// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Charts
import MarketInsight
import Primitives

struct ChartView: View {
    
    let model: ChartValuesViewModel
    
    static let date = "Date"
    static let value = "Value"
    
    @State private var selectedValue: ChartPriceModel? {
        didSet {
            if let selectedValue, selectedValue.date != oldValue?.date {
                vibrate()
            }
        }
    }

    init(
        model: ChartValuesViewModel
    ) {
        self.model = model
    }
    
    var body: some View {
        VStack {
            if let selectedValue {
                ChartPriceView.from(model: selectedValue)
            } else if let chartPriceModel = model.chartPriceModel {
                ChartPriceView.from(model: chartPriceModel)
            }
        }
        .padding(.top, Spacing.small)
        .padding(.bottom, Spacing.tiny)
        
        Chart {
            ForEach(model.charts, id: \.date) { item in
                LineMark(
                    x: .value(Self.date, item.date),
                    y: .value(Self.value, item.value)
                )
                .lineStyle(StrokeStyle(lineWidth: 3))
                .foregroundStyle(Colors.blue)
                .interpolationMethod(.cardinal)
            }
            if let selectedValue, let date = selectedValue.date {
                PointMark(
                    x: .value(Self.date, date),
                    y: .value(Self.value, selectedValue.price)
                )
                .symbol() {
                    Circle()
                        .strokeBorder(Colors.blue, lineWidth: 2)
                        .background(Circle()
                        .foregroundColor(Colors.white))
                        .frame(width: 12)
                }
                .foregroundStyle(Colors.blue)
                
                RuleMark(
                    x: .value(Self.date, date)
                )
                .foregroundStyle(Colors.blue)
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
            }
        }
        .chartOverlay { (proxy: ChartProxy) in
            GeometryReader { geometry in
                    Rectangle().fill(.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if let element = findElement(location: value.location, proxy: proxy, geometry: geometry) {
                                    let change = model.values.priceChange(base: model.values.firstValue, price: element.value)

                                    selectedValue = ChartPriceModel(
                                        period: model.period,
                                        date: element.date,
                                        price: change.price,
                                        priceChange: change.priceChange
                                    )
                                }
                            }.onEnded { _ in
                                selectedValue = .none
                            }
                    )
                }
        }
        .padding(.vertical, Spacing.large)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartYScale(domain: model.values.yScale)
        .chartBackground { proxy in
            ZStack(alignment: .topLeading) {
                GeometryReader { geo in
                    let maxWidth = 88.0

                    // lower
                    if let lowerBoundX = proxy.position(forX: model.values.lowerBoundDate), let lowerBoundY1 = proxy.position(forY: model.values.lowerBoundValue) {
                        let x = calculateX(x: lowerBoundX, maxWidth: maxWidth, geoWidth: geo.size.width)
                        Text(model.lowerBoundValueText)
                            .font(.caption2)
                            .foregroundColor(Colors.gray)
                            .frame(width: maxWidth)
                            .offset(x: x, y: lowerBoundY1 + Spacing.extraLarge)
                    }
                    // upper
                    if let lowerBoundX = proxy.position(forX: model.values.upperBoundDate) {
                        let x = calculateX(x: lowerBoundX, maxWidth: maxWidth, geoWidth: geo.size.width)
                        
                        Text(model.upperBoundValueText)
                            .font(.caption2)
                            .foregroundColor(Colors.gray)
                            .frame(maxWidth: maxWidth)
                            .offset(x: x, y: 0)
                    }
                }
            }
        }
        .padding(0)
    }
    
    private func findElement(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> ChartDateValue? {
        guard let plotFrame = proxy.plotFrame else {
            return .none
        }
        let relativeXPosition = location.x - geometry[plotFrame].origin.x
        
        if let date = proxy.value(atX: relativeXPosition) as Date? {
            // Find the closest date element.
            var minDistance: TimeInterval = .infinity
            var dataIndex: Int? = nil
            for (index, _) in model.charts.enumerated() {
                let nthSalesDataDistance = model.charts[index].date.distance(to: date)
                if abs(nthSalesDataDistance) < minDistance {
                    minDistance = abs(nthSalesDataDistance)
                    dataIndex = index
                }
            }
            if let dataIndex {
                return model.charts[dataIndex]
            }
        }
        return .none
    }
    
    func calculateX(x: CGFloat, maxWidth: CGFloat, geoWidth: CGFloat) -> CGFloat {
        let halfWidth = maxWidth / 2
        if x < halfWidth {
            return x - halfWidth/2
        } else {
            return min(x - halfWidth, geoWidth - maxWidth)
        }
    }
    
    func vibrate() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

extension ChartPriceView {
    static func from(model: ChartPriceModel) -> some View {
        ChartPriceView(
            date: model.dateText,
            price: model.priceText,
            priceChange: model.priceChangeText,
            priceChangeTextColor: model.priceChangeTextColor
        )
    }
}
