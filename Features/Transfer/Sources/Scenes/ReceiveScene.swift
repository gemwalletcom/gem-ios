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
            AssetImageView(assetImage: model.assetModel.assetImage, size: Sizing.image.large)
                .padding(.top, .medium)

            HStack(alignment: .bottom, spacing: .tiny) {
                Text(model.assetModel.name)
                    .textStyle(.headline)
                if let symbol = model.symbol {
                    Text(symbol)
                        .textStyle(.subheadline)
                }
            }
            .lineLimit(1)

            VStack {
                if let image = model.renderedImage {
                    qrCodeView(image: image)
                        .frame(maxWidth: model.qrWidth)
                }
                
                if let warning = try? AttributedString(markdown: model.warningMessage) {
                    Text(warning)
                        .textStyle(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, .medium)
                }
                
                Spacer()
                StateButton(
                    text: model.address,
                    image: Images.System.copy,
                    infoTitle: model.youAddressTitle,
                    truncationMode: .middle,
                    action: model.onCopyAddress
                )

                Button(action: model.onShareSheet) {
                    HStack {
                        Images.System.share
                            .foregroundStyle(Colors.secondaryText)
                        Text(model.shareTitle)
                            .textStyle(.bodySecondary)
                    }
                    .frame(width: .scene.button.maxWidth, height: .scene.button.height)
                }
                .liquidGlass()
            }
            .frame(maxWidth: .scene.button.maxWidth)
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
            .clipShape(RoundedRectangle(cornerRadius: .medium))
            .padding(.medium)
            .background(
                RoundedRectangle(cornerRadius: .extraLarge)
                    .fill(Colors.listStyleColor)
                    .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 5)
            )
    }
}
