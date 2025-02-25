// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import PrimitivesComponents

struct ReceiveScene: View {
    @State private var showShareSheet = false
    @State private var showCopyMessage = false
    @State private var renderedImage: UIImage?

    private let qrWidth: CGFloat = 300
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
                        .frame(maxWidth: qrWidth)
                }
                Spacer()
                Button(action: {
                    showShareSheet.toggle()
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
                    showShareSheet.toggle()
                } label: {
                    Images.System.share
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
        .task {
            await generateQRCode()
        }
        .taskOnce {
            model.enableAsset()
        }
    }
}

// MARK: - Actions

extension ReceiveScene {
    private func onCopyAddress() {
        showCopyMessage = true
        UIPasteboard.general.string = model.address
    }

    private func generateQRCode() async {
        let image = await generator.generate(
            from: model.address,
            size: CGSize(
                width: qrWidth,
                height: qrWidth
            ),
            logo: UIImage.name("logo-dark")
        )

        await MainActor.run {
            renderedImage = image
        }
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
