// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components
import QRScanner
import Blockchain
import Primitives

//struct RecipientScene: View {
//    
//    let model: RecipientViewModel
//
//    var body: some View {
//        VStack {
//            List {
//                if !model.getRecipient(by: .wallets).isEmpty {
//                    Section {
//                        ForEach(model.getRecipient(by: .wallets)) { recipient in
//                            NavigationCustomLink(with: ListItemView(title: recipient.name)) {
//                                //address = recipient.address
//                                //focusedField = .none
//                            }
//                        }
//                    } header: {
//                        Text("My Wallets")
//                    }
//                }
//                if !model.getRecipient(by: .view).isEmpty {
//                    Section {
//                        ForEach(model.getRecipient(by: .view)) { recipient in
//                            NavigationCustomLink(with: ListItemView(title: recipient.name)) {
//                                //address = recipient.address
//                                //focusedField = .none
//                            }
//                        }
//                    } header: {
//                        Text("View Wallets")
//                    }
//                }
//            }
//            .buttonStyle(.blue())
//            .padding(.bottom, Spacing.scene.bottom)
//            .frame(maxWidth: Spacing.scene.button.maxWidth)
//        }
//        .background(Colors.grayBackground)
//        .navigationTitle(model.tittle)
//    }
//}

//struct TransferScene_Previews: PreviewProvider {
//    static var previews: some View {
//        RecipientScene(
//            model: RecipientViewModel(
//                wallet: .main,
//                keystore: .main,
//                walletsService: .main,
//                assetModel: AssetViewModel(asset: .main)
//            )
//        )
//    }
//}
