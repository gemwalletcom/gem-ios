// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style

struct ReceiveScene: View {
    
    let model: ReceiveViewModel
    let generator = QRCodeGenerator()
    
    @State private var showShareSheet = false
    @State private var showCopyMessage = false
    @State private var renderedImage: UIImage?

    var body: some View {
        VStack {
            Spacer()
            ZStack {
                if let image = renderedImage {
                    Image(uiImage: image)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    LoadingView()
                }
            }
            .frame(width: 240, height: 240, alignment: .center)
            .padding(8)
            .padding(.bottom, 24)
            
            VStack {
                HStack {
                    Text(model.address)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .frame(maxWidth: .infinity)
                    Spacer()
                    Button(Localized.Common.copy, action: copyAddress)
                        .buttonStyle(.blue(paddingHorizontal: 8, paddingVertical: 6))
                        .fixedSize()
                }.padding(8)
            }
            .frame(maxWidth: 320)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Colors.grayLight, lineWidth: 0.5)
            )
            Spacer()
            Button(action: {
                showShareSheet.toggle()
            }) {
                Text(Localized.Common.share)
            }
            .buttonStyle(.blue())
            .padding(.bottom, Spacing.scene.bottom)
            .frame(maxWidth: Spacing.scene.button.maxWidth)
        }
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
            ShareSheet(activityItems: [model.sharableText])
        }
        .frame(maxWidth: .infinity)
        .modifier(
            ToastModifier(
                isPresenting: $showCopyMessage,
                value: CopyTypeViewModel(type: .address(model.assetModel.asset, address: model.addressShort)).message,
                systemImage: SystemImage.copy
            )
        )
        .navigationBarTitle(model.title)
        .taskOnce {
            generateQRCode()
            model.enableAsset()
            
            try? model.walletsService.updateNode(chain: model.assetModel.asset.chain)
        }
    }

    private func copyAddress() {
        showCopyMessage = true
        UIPasteboard.general.string = model.address
    }

    private func generateQRCode() {
        Task.detached(priority: .utility) {
            let image = await generator.generate(
                from: model.address,
                logo: UIImage(named: "logo")
            )

            await MainActor.run {
                renderedImage = image
            }
        }
    }
}

struct ReceiveScene_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ReceiveScene(
                model: ReceiveViewModel(assetModel: AssetViewModel(asset: .main), walletId: .main, address: "", walletsService: .main)
            )
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
