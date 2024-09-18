// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

struct LockScreenScene<Content: View>: View {
    @Environment(\.scenePhase) var scenePhase

    @State private var model: LockSceneViewModel
    private let content: Content

    init(
        model: LockSceneViewModel,
        @ViewBuilder content: () -> Content
    ) {
        self.model = model
        self.content = content()
    }

    var body: some View {
        ZStack {
            content
                .disabled(model.isLocked)

            if model.shouldShowPlaceholder {
                placeholderView
                    .overlay(alignment: .bottom) {
                        unlockButton
                    }
                    .onAppear() {
                        if model.isLocked {
                            unlock()
                        }
                    }
            }
        }
        .animation(.smooth, value: model.isLocked)
        .frame(maxWidth: .infinity)
        .onChange(of: scenePhase, onScenePhaseChange)
        .onChange(of: model.isLocked) { oldValue, newValue in
            if newValue {
                unlock()
            }
        }
    }
}

// MARK: - UI Components

extension LockScreenScene {
    @ViewBuilder
    private var unlockButton: some View {
        VStack(spacing: Spacing.medium) {
            if model.state == .lockedCanceled {
                Button(action: unlock) {
                    HStack {
                        Image(systemName: SystemImage.lock)
                        Text(model.unlockTitle)
                    }
                }
                .buttonStyle(.blue())
                .frame(maxWidth: Spacing.scene.button.maxWidth)
                .padding()
            }
        }
    }

    @ViewBuilder
    private var placeholderView: some View {
        ZStack {
            Image(.logoLaunch)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 128, height: 128)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Colors.white)
    }
}

// MARK: - Actions

extension LockScreenScene {
    @MainActor
    private func onScenePhaseChange(_: ScenePhase, _ phase: ScenePhase) {
        model.handleSceneChange(to: phase)
    }

    private func unlock() {
        Task {
            await model.unlock()
        }
    }
}

// MARK: - Previews

#Preview {
    LockScreenScene(model: .init()) { }
}
