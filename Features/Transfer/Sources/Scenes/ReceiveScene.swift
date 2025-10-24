// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import PrimitivesComponents

public struct ReceiveScene: View {
    @State private var model: ReceiveViewModel

    public init(model: ReceiveViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        VStack(spacing: .large) {
            AssetImageView(assetImage: model.assetModel.assetImage, size: .image.semiLarge)
                .padding(.top, .medium)

            HStack(alignment: .bottom, spacing: .tiny) {
                Text(model.assetModel.name)
                    .textStyle(.headline)
                if let symbol = model.symbol {
                    Text(symbol)
                        .textStyle(TextStyle(font: .subheadline, color: Colors.secondaryText, fontWeight: .medium))
                }
            }
            .lineLimit(1)

            VStack {
                Spacer()
                if let image = model.renderedImage {
                    qrCodeView(image: image)
                        .frame(maxWidth: model.qrWidth)
                    .padding(.medium)
                    .background(
                        RoundedRectangle(cornerRadius: .medium)
                            .fill(Colors.listStyleColor)
                            .shadow(color: Color.black.opacity(Sizing.shadow.opacity), radius: Sizing.shadow.radius, x: .zero, y: Sizing.shadow.yOffset)
                    )
                }
                Text(model.warningMessage)
                    .textStyle(.subHeadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, .medium)
                    .padding(.top, .small)
                    .frame(maxWidth: model.qrWidth)
                Spacer()
            }
            .frame(maxWidth: .scene.button.maxWidth)
            
            Button(action: model.onCopyAddress) {
                HStack {
                    Images.System.copy
                        .foregroundStyle(Colors.secondaryText)
                    Text(model.addressShort)
                        .textStyle(.bodySecondary)
                        .truncationMode(.middle)
                }
                .padding()
                .frame(width: .scene.button.maxWidth, height: .scene.button.height)
            }
            .liquidGlass()
        }
        .padding(.bottom, .scene.bottom)
        .frame(maxWidth: .infinity)
        .navigationBarTitle(model.title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: model.onShareSheet) {
                    Images.System.share
                }
            }
        }
        .sheet(isPresented: $model.isPresentingShareSheet) {
            ShareSheet(activityItems: model.activityItems(qrImage: model.renderedImage))
        }
        .copyToast(
            model: model.copyModel,
            isPresenting: $model.isPresentingCopyToast
        )
        .task {
            await model.onLoadImage()
        }
        .taskOnce {
            Task {
                await model.enableAsset()
            }
        }
    }
}

// MARK: - UI Components

extension ReceiveScene {
    @ViewBuilder
    private func qrCodeView(image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .padding(.extraSmall)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: .small))
    }
}
