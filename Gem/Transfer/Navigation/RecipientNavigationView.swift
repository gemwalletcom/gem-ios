// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Transfer
import ChainService
import PrimitivesComponents
import WalletsService
import Contacts

struct RecipientNavigationView: View {
    @Environment(\.keystore) private var keystore
    @Environment(\.walletsService) private var walletsService
    @Environment(\.nodeService) private var nodeService
    @Environment(\.contactService) private var contactService
    
    private let onComplete: VoidAction

    @Binding private var navigationPath: NavigationPath
        
    @State var model: RecipientViewModel

    init(
        model: RecipientViewModel,
        navigationPath: Binding<NavigationPath>,
        onComplete: VoidAction
    ) {
        self.model = model
        _navigationPath = navigationPath
        self.onComplete = onComplete
    }
    
    var body: some View {
        RecipientScene(
            model: model
        )
        .navigationDestination(for: RecipientData.self) { data in
            AmountNavigationView(
                input: AmountInput(type: .transfer(recipient: data), asset: model.asset),
                wallet: model.wallet,
                navigationPath: $navigationPath
            )
        }
        .navigationDestination(for: TransferData.self) { data in
            ConfirmTransferScene(
                model: ConfirmTransferViewModel(
                    wallet: model.wallet,
                    keystore: keystore,
                    data: data,
                    service: ChainServiceFactory(nodeProvider: nodeService)
                        .service(for: data.chain),
                    walletsService: walletsService,
                    onComplete: onComplete
                )
            )
        }
    }
}
