// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Components
import Style

public struct BannerView: View {

    private static let autoAdvanceInterval: TimeInterval = 3.0
    private static let animationDuration: TimeInterval = 0.3

    let banners: [BannerViewModel]
    private let action: ((Banner) -> Void)
    private let closeAction: ((Banner) -> Void)
    
    @State private var currentIndex: Int = 0
    @State private var isUserInteracting: Bool = false
    
    private let timer = Timer.publish(every: autoAdvanceInterval, on: .main, in: .common).autoconnect()

    public init(
        banners: [Banner],
        action: @escaping (Banner) -> Void,
        closeAction: @escaping (Banner) -> Void
    ) {
        self.banners = banners.map(BannerViewModel.init)
        self.action = action
        self.closeAction = closeAction
    }

    public var body: some View {
        if banners.isEmpty {
            EmptyView()
        } else {
            VStack(spacing: 0) {
                carouselTabView
                if banners.count > 1 {
                    carouselIndicators
                }
            }
        }
    }
}

// MARK: - Private Views

private extension BannerView {
    var carouselTabView: some View {
        TabView(selection: $currentIndex) {
            ForEach(banners.indices, id: \.self) { index in
                bannerView(for: banners[index])
                    .tag(index)
            }
        }
        .frame(height: .scene.bannerHeight)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .simultaneousGesture(
            DragGesture(minimumDistance: .zero)
                .onChanged { _ in
                    isUserInteracting = true
                }
                .onEnded { _ in
                    Task {
                        try? await Task.sleep(for: .seconds(Int(Self.autoAdvanceInterval)))
                        isUserInteracting = false
                    }
                }
        )
        .onReceive(timer) { _ in
            guard banners.count > 1, !isUserInteracting else { return }
            withAnimation(.easeInOut(duration: Self.animationDuration)) {
                currentIndex = (currentIndex + 1) % banners.count
            }
        }
    }
    
    @ViewBuilder
    var carouselIndicators: some View {
        HStack(spacing: .tiny) {
            ForEach(0..<banners.count, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? Colors.blue : Colors.gray.opacity(0.3))
                    .frame(size: .space6)
            }
        }
        .padding(.top, Spacing.extraSmall)
    }
    
    func bannerView(for model: BannerViewModel) -> some View {
        Button(
            action: { action(model.banner) },
            label: {
                HStack(spacing: 0) {
                    ListItemView(
                        title: model.title,
                        titleExtra: model.description,
                        imageStyle: model.imageStyle
                    )

                    if model.canClose {
                        Spacer()

                        ListButton(
                            image: Images.System.xmarkCircle,
                            action: { closeAction(model.banner) }
                        )
                        .padding(.vertical, .small)
                        .foregroundColor(Colors.gray)
                    }
                }
            }
        )
        .buttonStyle(PlainButtonStyle())
    }
}

