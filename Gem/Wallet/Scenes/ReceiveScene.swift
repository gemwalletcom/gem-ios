// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style

struct ReceiveScene: View {
    @Environment(\.colorScheme) private var scheme

    @State private var showShareSheet = false
    @State private var showCopyMessage = false
    @State private var renderedImage: UIImage?

    private let model: ReceiveViewModel
    private let generator = QRCodeGenerator()

    init(model: ReceiveViewModel) {
        self.model = model
    }

    var body: some View {
        VStack {
            VStack {
                Spacer()
                if let image = renderedImage {
                    qrCodeView(image: image)
                        .transition(.opacity)
                }
                Spacer()
                Button(action: {
                    showShareSheet.toggle()
                }) {
                    Text(model.shareTitle)
                }
                .buttonStyle(.blue())
            }
            .animation(.easeInOut, value: renderedImage != nil)
            .frame(maxWidth: Spacing.scene.button.maxWidth)
        }
        .padding(.bottom, Spacing.scene.bottom)
        .frame(maxWidth: .infinity)
        .background(Colors.grayBackground)
        .navigationBarTitle(model.title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showShareSheet.toggle()
                } label: {
                    Image(systemName: SystemImage.share)
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [model.address])
        }
        .modifier(
            ToastModifier(
                isPresenting: $showCopyMessage,
                value: CopyTypeViewModel(type: .address(model.assetModel.asset, address: model.addressShort)).message,
                systemImage: SystemImage.copy
            )
        )
        .taskOnce {
            generateQRCode()
            model.enableAsset()
            
            try? model.walletsService.updateNode(chain: model.assetModel.asset.chain)
        }
    }
}

// MARK: - Actions

extension ReceiveScene {
    private func onCopyAddress() {
        showCopyMessage = true
        UIPasteboard.general.string = model.address
    }

    private func generateQRCode() {
        Task.detached(priority: .utility) {
            let image = await generator.generate(
                from: model.address,
                size: CGSize(
                    width: Spacing.scene.button.maxWidth,
                    height: Spacing.scene.button.maxWidth
                ),
                logo: UIImage(named: "logo-dark")
            )

            await MainActor.run {
                renderedImage = image
            }
        }
    }
}

// MARK: - UI Components

extension ReceiveScene {
    @ViewBuilder
    private func qrCodeView(image: UIImage) -> some View {
        VStack(spacing: Spacing.medium) {
            Image(uiImage: image)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .padding(scheme == .dark ? Spacing.small : .zero)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: Spacing.medium))

            HStack(spacing: Spacing.small) {
                AssetImageView(assetImage: model.assetModel.assetImage)
                VStack(alignment: .leading, spacing: Spacing.extraSmall) {
                    Text(model.youAddressTitle)
                        .font(.subheadline.weight(.semibold))
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
                    .padding(.all, Spacing.small)
                    .background(
                        RoundedRectangle(cornerRadius: Spacing.small)
                            .fill(Colors.grayVeryLight)
                    )
                    .buttonStyle(.plain)
            }
        }
        .padding(Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: Spacing.medium)
                .fill(Colors.listStyleColor)
                .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 5)
        )
    }
}
