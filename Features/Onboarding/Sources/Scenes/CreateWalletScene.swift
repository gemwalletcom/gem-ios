import SwiftUI
import Style
import Primitives
import Components
import Localization
import PrimitivesComponents

struct CreateWalletScene: View {

    @StateObject var model: CreateWalletViewModel
    
    @State private var showCopyMessage = false
    
    var body: some View {
        VStack(spacing: .medium) {
            
            OnboardingHeaderTitle(title: Localized.SecretPhrase.savePhraseSafely)
            SecretDataTypeView(type: model.type)

            Button(action: copy) {
                Text(Localized.Common.copy)
            }
            Spacer()
            Button(Localized.Common.continue, action: continueAction)
                .buttonStyle(.blue())
                .frame(maxWidth: .scene.button.maxWidth)
        }
        .padding(.bottom, .scene.bottom)
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
