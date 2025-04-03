// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import PrimitivesComponents

struct ReceiveScene: View {
    @State private var isPresentingShareSheet = false
    @State private var isPresentingCopyToast = false
    @State private var renderedImage: UIImage?

    private let model: ReceiveViewModel

    init(model: ReceiveViewModel) {
        self.model = model
    }

    var body: some View {
        VStack {
            VStack {
                Spacer()
                if let image = renderedImage {
                    qrCodeView(image: image)
                        .frame(maxWidth: model.qrWidth)
                }
                Spacer()
                Button(action: {
                    isPresentingShareSheet.toggle()
                }) {
                    Text(model.shareTitle)
                }
                .buttonStyle(.blue())
            }
            .frame(maxWidth: .scene.button.maxWidth)
        }
        .padding(.bottom, .scene.bottom)
        .frame(maxWidth: .infinity)
        .background(Colors.grayBackground)
        .navigationBarTitle(model.title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isPresentingShareSheet.toggle()
                } label: {
                    Images.System.share
                }
            }
        }
        .sheet(isPresented: $isPresentingShareSheet) {
            ShareSheet(activityItems: model.activityItems(qrImage: renderedImage))
        }
        .copyToast(
            model: model.copyModel,
            isPresenting: $isPresentingCopyToast
        )
        .task {
            let image = await model.generateQRCode()
            await MainActor.run {
                renderedImage = image
            }
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
        isPresentingCopyToast = true
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
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Colors.black)
                    .padding(.all, .small)
                    .background(
                        RoundedRectangle(cornerRadius: .small)
                            .fill(Colors.grayVeryLight)
                    )
                    .buttonStyle(.plain)
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
