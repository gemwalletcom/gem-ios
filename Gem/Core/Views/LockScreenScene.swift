// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

struct LockScreenScene: View {
    @State private var model: LockSceneViewModel

    init(model: LockSceneViewModel) {
        self.model = model
    }

    var body: some View {
        ZStack {
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
        .animation(.smooth, value: model.isLocked)
        .frame(maxWidth: .infinity)
        .onChange(of: model.isLocked) { oldsState, newState in
            if newState {
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
                        Image(systemName: model.unlockImage)
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
    var placeholderView: some View {
        LogoView()
        .background(Colors.white)
    }
}

// MARK: - Actions

extension LockScreenScene {
    private func unlock() {
        Task {
            await model.unlock()
        }
    }
}

// MARK: - Previews

#Preview {
    LockScreenScene(model: .init())
}
