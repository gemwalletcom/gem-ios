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
        .copyToast(
            model: model.copyModel,
            isPresenting: $showCopyMessage
        )
        .padding(.bottom, .scene.bottom)
        .navigationBarTitle(model.title)
        .taskOnce {
            model.words = model.generateWords()
        }
    }
    
    func copy() {
        showCopyMessage = true
    }
    
    func continueAction() {
        model.continueAction()
    }
}
