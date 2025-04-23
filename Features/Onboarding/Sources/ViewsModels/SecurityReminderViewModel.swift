// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Style
import Localization

protocol SecurityReminderViewModel {
    var title: String { get }
    var message: String { get }
    var items: [SecurityReminderItem] { get }
    var checkmarkTitle: String { get }
    var buttonTitle: String { get }
    var docsUrl: URL { get }
    
    var onNext: () -> Void { get }
    var buttonState: StateViewType<Bool> { get }
    var isConfirmed: Bool { get set }
}
