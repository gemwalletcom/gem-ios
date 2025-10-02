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
        VStack {
            VStack {
                Spacer()
                if let image = model.renderedImage {
                    qrCodeView(image: image)
                        .frame(maxWidth: model.qrWidth)
                }
                Spacer()
                StateButton(
                    text: model.shareTitle,
                    action: model.onShareSheet
                )
            }
            .frame(maxWidth: .scene.button.maxWidth)
        }
        .padding(.bottom, .scene.bottom)
        .frame(maxWidth: .infinity)
        .background(Colors.grayBackground)
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

// MARK: - Actions

extension ReceiveScene {
    private func onCopyAddress() {
        model.onCopyAddress()
    }
}

// MARK: - UI Components

extension ReceiveScene {
    @ViewBuilder
    private func qrCodeView(image: UIImage) -> some View {
        VStack(spacing: .medium) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .padding(.extraSmall)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: .medium))

            HStack(spacing: .small) {
                AssetImageView(assetImage: model.assetModel.assetImage)
                VStack(alignment: .leading, spacing: .extraSmall) {
                    Text(model.youAddressTitle)
                        .font(.subheadline.weight(.semibold))
                        .minimumScaleFactor(0.8)
                        .foregroundStyle(Colors.black)
                    Text(model.address)
                        .textStyle(.calloutSecondary)
                }
                .lineLimit(1)
                .truncationMode(.middle)
                .frame(maxWidth: .infinity)

                Button(model.copyTitle, action: onCopyAddress)
                    .fixedSize()
                    .buttonStyle(.lightGray(paddingHorizontal: .small, paddingVertical: .small))
            }
        }
        .padding(.medium)
        .background(
            RoundedRectangle(cornerRadius: .medium)
                .fill(Colors.listStyleColor)
                .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 5)
        )
    }
}
