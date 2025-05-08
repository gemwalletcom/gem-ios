import SwiftUI
import Style
import Primitives
import Components
import Localization
import PrimitivesComponents

struct CreateWalletScene: View {

    @State var model: CreateWalletViewModel
    
    @State private var isPresentingCopyToast = false
    
    init(model: CreateWalletViewModel) {
        self.model = model
    }

    var body: some View {
        VStack(spacing: .medium) {
            OnboardingHeaderTitle(title: Localized.SecretPhrase.savePhraseSafely, alignment: .center)
            SecretDataTypeView(type: model.type)

            Button(action: copy) {
                Text(Localized.Common.copy)
            }
            Spacer()
            
            StateButton(
                text: Localized.Common.continue,
                styleState: .normal,
                action: continueAction
            )
            .frame(maxWidth: .scene.button.maxWidth)
        }
        .copyToast(
            model: model.copyModel,
            isPresenting: $isPresentingCopyToast
        )
        .padding(.bottom, .scene.bottom)
        .navigationBarTitle(model.title)
        .taskOnce {
            model.words = model.generateWords()
        }
    }
    
    func copy() {
        isPresentingCopyToast = true
    }
    
    func continueAction() {
        model.onNext()
    }
}
