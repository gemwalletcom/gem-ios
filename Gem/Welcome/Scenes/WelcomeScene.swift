import SwiftUI
import Style

struct WelcomeScene: View {
    
    @State private var isPresentingCreateWalletSheet = false
    @State private var isPresentingImportWalletSheet = false
    
    let model: WelcomeViewModel
    
    init(
        model: WelcomeViewModel
    ) {
        self.model = model
    }
    
    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .center, spacing: 24) {
    //            Text(Localized.Welcome.title)
    //                .fontWeight(.bold)
    //                .font(.system(size: 42))
    //                .padding(.bottom, 16)
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
            //TODO: Enable
    //        Text(.init(model.legalText))
    //            .multilineTextAlignment(.center)
    //            .font(.footnote)
    //            .foregroundColor(Colors.grayLight)
    //            .fontWeight(.light)
    //            .padding(Spacing.scene.bottom)
            .sheet(isPresented: $isPresentingCreateWalletSheet) {
                CreateWalletNavigationStack(isPresenting: $isPresentingCreateWalletSheet)
            }
            .sheet(isPresented: $isPresentingImportWalletSheet) {
                ImportWalletNavigationStack(isPresenting: $isPresentingImportWalletSheet)
            }
        }
        .overlay(
            ZStack {
                Image(.logo)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 128, height: 128)
            }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        )
        .frame(maxWidth: .infinity)
        .background(Colors.white)
        .navigationTitle(model.title)
    }
}

//struct WelcomeScene_Previews: PreviewProvider {
//    static var previews: some View {
//        WelcomeScene(model: WelcomeViewModel(keystore: .main))
//    }
//}
