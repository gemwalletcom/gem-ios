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
                .blur(radius: model.blur)
                .disabled(model.isLocked)

            if model.isLocked {
                Rectangle()
                    .ignoresSafeArea()
                    .foregroundStyle(.clear)
                    .overlay(alignment: .bottom) {
                        unlockButton
                    }
                    .onAppear {
                        unlock()
                    }
            }
        }
        .animation(.smooth, value: model.blur)
        .frame(maxWidth: .infinity)
        .onChange(of: scenePhase, onScenePhaseChange)
    }
}

// MARK: - UI Components

extension LockScreenScene {
    @ViewBuilder
    private var unlockButton: some View {
        VStack(spacing: Spacing.medium) {
            if model.state == .lockedCanceled {
                Button(action: unlock) {
                    Text(model.unlockTitle)
                }
                .buttonStyle(.blue())
                .frame(maxWidth: Spacing.scene.button.maxWidth)
                .padding()
            }
        }
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
