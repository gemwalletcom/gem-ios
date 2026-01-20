// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Charts
import Primitives

private struct ChartKey {
    static let date = "Date"
    static let value = "Value"
}

public struct ChartView: View {
    private let model: ChartValuesViewModel

    @State private var selectedValue: ChartPriceViewModel? {
        didSet {
            if let selectedValue, selectedValue.date != oldValue?.date {
                vibrate()
            }
        }
    }

    public init(model: ChartValuesViewModel) {
        self.model = model
    }

    public var body: some View {
        VStack {
            if let selectedValue {
                ChartPriceView(model: selectedValue)
            } else if let chartPriceViewModel = model.chartPriceViewModel {
                ChartPriceView(model: chartPriceViewModel)
            }
        }
        .padding(.top, Spacing.small)
        .padding(.bottom, Spacing.tiny)

        Chart {
            ForEach(model.charts, id: \.date) { item in
                LineMark(
                    x: .value(ChartKey.date, item.date),
                    y: .value(ChartKey.value, item.value)
                )
                .lineStyle(StrokeStyle(lineWidth: 3))
                .foregroundStyle(model.lineColor)
                .interpolationMethod(.cardinal)
            }
            if let selectedValue, let date = selectedValue.date {
                PointMark(
                    x: .value(ChartKey.date, date),
                    y: .value(ChartKey.value, selectedValue.price)
                )
                .symbol {
                    Circle()
                        .strokeBorder(model.lineColor, lineWidth: 2)
                        .background(Circle().foregroundColor(Colors.white))
                        .frame(width: 12)
                }
                .foregroundStyle(model.lineColor)

                RuleMark(x: .value(ChartKey.date, date))
                    .foregroundStyle(model.lineColor)
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
                                    selectedValue = model.priceViewModel(for: element)
                                }
                            }
                            .onEnded { _ in
                                selectedValue = nil
                            }
                    )
            }
        }
        .padding(.vertical, Spacing.large)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartYScale(domain: model.values.yScale)
        .chartXScale(domain: model.values.xScale)
        .chartBackground { proxy in
            ZStack(alignment: .topLeading) {
                GeometryReader { geo in
                    let maxWidth = 88.0

                    if let plotFrame = proxy.plotFrame {
                        let chartBounds = geo[plotFrame]

                        if let lowerBoundX = proxy.position(forX: model.values.lowerBoundDate) {
                            let x = calculateX(x: lowerBoundX, maxWidth: maxWidth, geoWidth: geo.size.width)
                            Text(model.lowerBoundValueText)
                                .font(.caption2)
                                .foregroundColor(Colors.gray)
                                .frame(width: maxWidth)
                                .offset(x: x, y: chartBounds.maxY + Spacing.small)
                        }

                        if let upperBoundX = proxy.position(forX: model.values.upperBoundDate) {
                            let x = calculateX(x: upperBoundX, maxWidth: maxWidth, geoWidth: geo.size.width)
                            Text(model.upperBoundValueText)
                                .font(.caption2)
                                .foregroundColor(Colors.gray)
                                .frame(width: maxWidth)
                                .offset(x: x, y: chartBounds.minY - Spacing.large)
                        }
                    }
                }
            }
        }
        .padding(0)
    }
}

// MARK: - Private

extension ChartView {
    private func findElement(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> ChartDateValue? {
        guard let plotFrame = proxy.plotFrame else { return nil }
        let relativeXPosition = location.x - geometry[plotFrame].origin.x

        if let date = proxy.value(atX: relativeXPosition) as Date? {
            var minDistance: TimeInterval = .infinity
            var dataIndex: Int?
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
        return nil
    }

    private func calculateX(x: CGFloat, maxWidth: CGFloat, geoWidth: CGFloat) -> CGFloat {
        let halfWidth = maxWidth / 2
        if x < halfWidth {
            return x - halfWidth / 2
        } else {
            return min(x - halfWidth, geoWidth - maxWidth)
        }
    }

    private func vibrate() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
