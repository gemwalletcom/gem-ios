import SwiftUI
import Style
import Primitives
import Components

struct CreateWalletScene: View {

    @StateObject var model: CreateWalletViewModel
    
    @State private var showCopyMessage = false
    
    var body: some View {
        VStack(spacing: Spacing.medium) {
            
            OnboardingHeaderTitle(title: Localized.SecretPhrase.savePhraseSafely)

            SecretDataTypeView(type: model.type)

            Button(action: copy) {
                Text(Localized.Common.copy)
            }
            Spacer()
            Button(Localized.Common.continue, action: continueAction)
                .buttonStyle(.blue())
                .frame(maxWidth: Spacing.scene.button.maxWidth)
        }
        .padding(.bottom, Spacing.scene.bottom)
        .navigationBarTitle(model.title)
        .taskOnce {
            model.words = model.generateWords()
        }
        .modifier(ToastModifier(
            isPresenting: $showCopyMessage,
            value: CopyTypeViewModel(type: .secretPhrase).message,
            systemImage: SystemImage.copy
        ))
    }
    
    func copy() {
        showCopyMessage = true
        UIPasteboard.general.string = MnemonicFormatter.fromArray(words: model.words)
    }
    
    func continueAction() {
        model.continueAction()
    }
}

//struct CreateWalletScene_Previews: PreviewProvider {
//    @State static var isShowSheet = false
//    static var previews: some View {
//        CreateWalletScene(model: CreateWalletViewModel(keystore: .main))
//    }
//}
