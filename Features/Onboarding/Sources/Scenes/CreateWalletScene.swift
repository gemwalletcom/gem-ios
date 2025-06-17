import SwiftUI
import Style
import Primitives
import Components
import Localization
import PrimitivesComponents

struct CreateWalletScene: View {

    @StateObject var model: CreateWalletViewModel
    
    @State private var isPresentingCopyToast = false

    var body: some View {
        VStack(spacing: .medium) {
            List {
                Section {
                    OnboardingHeaderTitle(
                        title: Localized.SecretPhrase.savePhraseSafely,
                        alignment: .center
                    )
                }
                .cleanListRow()
                
                Section {
                    SecretDataTypeView(
                        type: model.type
                    )
                }
                .cleanListRow()

                ListButton(
                    title: Localized.Common.copy,
                    image: Images.System.copy,
                    action: copy
                )
                .frame(maxWidth: .infinity, alignment: .center)
                .cleanListRow()
            }
            .contentMargins([.top], .extraSmall, for: .scrollContent)
            .listSectionSpacing(.custom(.medium))

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
        .toolbarInfoButton(url: model.docsUrl)
        .padding(.bottom, .scene.bottom)
        .background(Colors.grayBackground)
        .navigationBarTitle(model.title)
        .taskOnce { model.generateWords() }
    }
    
    func copy() {
        isPresentingCopyToast = true
    }
    
    func continueAction() {
        model.continueAction()
    }
}
