// Copyright (c). Gem Wallet. All rights reserved.

public enum EntityEditorViewType {
    case create
    case update
    
    public func title(objectName: String) -> String {
        switch self {
        case .create:
            return "Add \(objectName)"
        case .update:
            return "Edit \(objectName)"
        }
    }
}
