import SwiftUI
import Style
import Keystore

struct WelcomeScene: View {

    @State private var isPresentingCreateWalletSheet = false
    @State private var isPresentingImportWalletSheet = false

    private let model: WelcomeViewModel

    init(model: WelcomeViewModel) {
        self.model = model
    }

    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .center, spacing: 24) {
                Button(Localized.Wallet.createNewWallet) {
                    isPresentingCreateWalletSheet.toggle()
                }
                .buttonStyle(.blue())
                .accessibilityIdentifier("welcome_create")
                Button(Localized.Wallet.importExistingWallet) {
                    isPresentingImportWalletSheet.toggle()
                }
                .buttonStyle(.blue())
                .accessibilityIdentifier("welcome_import")
            }
            .frame(maxWidth: Spacing.scene.button.maxWidth)
            .padding(Spacing.scene.bottom * 2)
        }
        .overlay(
            LogoView()
        )
        .frame(maxWidth: .infinity)
        .background(Colors.white)
        .navigationTitle(model.title)
        .sheet(isPresented: $isPresentingCreateWalletSheet) {
            CreateWalletNavigationStack()
        }
        .sheet(isPresented: $isPresentingImportWalletSheet) {
            ImportWalletNavigationStack()
        }
    }
}

// MARK: - Previews

#Preview {
    WelcomeScene(model: .init())
}
