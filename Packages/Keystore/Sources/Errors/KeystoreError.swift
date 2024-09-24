import Foundation

enum KeystoreError: LocalizedError {
    //case unknownWallet
    case unknownWalletIdInWalletCore
    case unknownWalletInWalletCoreList
    case unknownWalletInWalletCore
    case invalidPrivateKey
    case noWallet
    case noWalletId

    var errorDescription: String? {
        switch self {
//        case .unknownWallet:
//            "Unknown wallet or Keychain has been reset"
        case .unknownWalletIdInWalletCore:
            "Unknown wallet ID in Wallet core"
        case .unknownWalletInWalletCoreList:
            "Unknown wallet in Wallet core list"
        case .unknownWalletInWalletCore:
            "Unknown wallet in Wallet core"
        case .invalidPrivateKey:
            "Invalid private key"
        case .noWallet:
            "No wallet found"
        case .noWalletId:
            "No wallet id"
        }
    }
}
