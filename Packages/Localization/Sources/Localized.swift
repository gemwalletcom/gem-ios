// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum Localized {
  public enum Activity {
    /// Activity
    public static let title = Localized.tr("Localizable", "activity.title", fallback: "Activity")
    public enum EmptyState {
      /// No activity yet.
      public static let message = Localized.tr("Localizable", "activity.empty_state.message", fallback: "No activity yet.")
    }
  }
  public enum App {
    /// Gem
    public static let name = Localized.tr("Localizable", "app.name", fallback: "Gem")
  }
  public enum Asset {
    /// Balances
    public static let balances = Localized.tr("Localizable", "asset.balances", fallback: "Balances")
    /// Circulating Supply
    public static let circulatingSupply = Localized.tr("Localizable", "asset.circulating_supply", fallback: "Circulating Supply")
    /// Contract
    public static let contract = Localized.tr("Localizable", "asset.contract", fallback: "Contract")
    /// Decimals
    public static let decimals = Localized.tr("Localizable", "asset.decimals", fallback: "Decimals")
    /// Latest Transactions
    public static let latestTransactions = Localized.tr("Localizable", "asset.latest_transactions", fallback: "Latest Transactions")
    /// Market Cap
    public static let marketCap = Localized.tr("Localizable", "asset.market_cap", fallback: "Market Cap")
    /// Market Cap Rank
    public static let marketCapRank = Localized.tr("Localizable", "asset.market_cap_rank", fallback: "Market Cap Rank")
    /// Name
    public static let name = Localized.tr("Localizable", "asset.name", fallback: "Name")
    /// Price
    public static let price = Localized.tr("Localizable", "asset.price", fallback: "Price")
    /// Symbol
    public static let symbol = Localized.tr("Localizable", "asset.symbol", fallback: "Symbol")
    /// Token ID
    public static let tokenId = Localized.tr("Localizable", "asset.token_id", fallback: "Token ID")
    /// Total Supply
    public static let totalSupply = Localized.tr("Localizable", "asset.total_supply", fallback: "Total Supply")
    /// Trading Volume (24h)
    public static let tradingVolume = Localized.tr("Localizable", "asset.trading_volume", fallback: "Trading Volume (24h)")
    /// View address on %@
    public static func viewAddressOn(_ p1: Any) -> String {
      return Localized.tr("Localizable", "asset.view_address_on", String(describing: p1), fallback: "View address on %@")
    }
    /// View token on %@
    public static func viewTokenOn(_ p1: Any) -> String {
      return Localized.tr("Localizable", "asset.view_token_on", String(describing: p1), fallback: "View token on %@")
    }
    public enum Balances {
      /// Available
      public static let available = Localized.tr("Localizable", "asset.balances.available", fallback: "Available")
      /// Reserved
      public static let reserved = Localized.tr("Localizable", "asset.balances.reserved", fallback: "Reserved")
    }
  }
  public enum Assets {
    /// Add Custom Token
    public static let addCustomToken = Localized.tr("Localizable", "assets.add_custom_token", fallback: "Add Custom Token")
    /// Hidden
    public static let hidden = Localized.tr("Localizable", "assets.hidden", fallback: "Hidden")
    /// No assets found
    public static let noAssetsFound = Localized.tr("Localizable", "assets.no_assets_found", fallback: "No assets found")
    /// Select Asset
    public static let selectAsset = Localized.tr("Localizable", "assets.select_asset", fallback: "Select Asset")
  }
  public enum Banner {
    public enum AccountActivation {
      /// The %@ network requires a one time fee of %@.
      public static func description(_ p1: Any, _ p2: Any) -> String {
        return Localized.tr("Localizable", "banner.account_activation.description", String(describing: p1), String(describing: p2), fallback: "The %@ network requires a one time fee of %@.")
      }
      /// %@ Account Activation Fee
      public static func title(_ p1: Any) -> String {
        return Localized.tr("Localizable", "banner.account_activation.title", String(describing: p1), fallback: "%@ Account Activation Fee")
      }
    }
    public enum ActivateAsset {
      /// To use the %@ asset, you must first enable it on the %@ network by fulfilling the network’s specific requirements.
      public static func description(_ p1: Any, _ p2: Any) -> String {
        return Localized.tr("Localizable", "banner.activate_asset.description", String(describing: p1), String(describing: p2), fallback: "To use the %@ asset, you must first enable it on the %@ network by fulfilling the network’s specific requirements.")
      }
    }
    public enum EnableNotifications {
      /// Stay on top of your wallet activity.
      public static let description = Localized.tr("Localizable", "banner.enable_notifications.description", fallback: "Stay on top of your wallet activity.")
      /// Enable Notifications
      public static let title = Localized.tr("Localizable", "banner.enable_notifications.title", fallback: "Enable Notifications")
    }
    public enum Stake {
      /// Earn %@ rewards on your stake while you sleep.
      public static func description(_ p1: Any) -> String {
        return Localized.tr("Localizable", "banner.stake.description", String(describing: p1), fallback: "Earn %@ rewards on your stake while you sleep.")
      }
      /// Start staking %@
      public static func title(_ p1: Any) -> String {
        return Localized.tr("Localizable", "banner.stake.title", String(describing: p1), fallback: "Start staking %@")
      }
    }
  }
  public enum Buy {
    /// No quotes available
    public static let noResults = Localized.tr("Localizable", "buy.no_results", fallback: "No quotes available")
    /// Rate
    public static let rate = Localized.tr("Localizable", "buy.rate", fallback: "Rate")
    /// Buy %s
    public static func title(_ p1: UnsafePointer<CChar>) -> String {
      return Localized.tr("Localizable", "buy.title", p1, fallback: "Buy %s")
    }
    public enum Providers {
      /// Providers
      public static let title = Localized.tr("Localizable", "buy.providers.title", fallback: "Providers")
    }
  }
  public enum Charts {
    /// All
    public static let all = Localized.tr("Localizable", "charts.all", fallback: "All")
    /// 1D
    public static let day = Localized.tr("Localizable", "charts.day", fallback: "1D")
    /// 1H
    public static let hour = Localized.tr("Localizable", "charts.hour", fallback: "1H")
    /// 1M
    public static let month = Localized.tr("Localizable", "charts.month", fallback: "1M")
    /// 1W
    public static let week = Localized.tr("Localizable", "charts.week", fallback: "1W")
    /// 1Y
    public static let year = Localized.tr("Localizable", "charts.year", fallback: "1Y")
  }
  public enum Common {
    /// Address
    public static let address = Localized.tr("Localizable", "common.address", fallback: "Address")
    /// All
    public static let all = Localized.tr("Localizable", "common.all", fallback: "All")
    /// Back
    public static let back = Localized.tr("Localizable", "common.back", fallback: "Back")
    /// Cancel
    public static let cancel = Localized.tr("Localizable", "common.cancel", fallback: "Cancel")
    /// Continue
    public static let `continue` = Localized.tr("Localizable", "common.continue", fallback: "Continue")
    /// Copied: %@
    public static func copied(_ p1: Any) -> String {
      return Localized.tr("Localizable", "common.copied", String(describing: p1), fallback: "Copied: %@")
    }
    /// Copy
    public static let copy = Localized.tr("Localizable", "common.copy", fallback: "Copy")
    /// Delete
    public static let delete = Localized.tr("Localizable", "common.delete", fallback: "Delete")
    /// Are sure you want to delete %s?
    public static func deleteConfirmation(_ p1: UnsafePointer<CChar>) -> String {
      return Localized.tr("Localizable", "common.delete_confirmation", p1, fallback: "Are sure you want to delete %s?")
    }
    /// Done
    public static let done = Localized.tr("Localizable", "common.done", fallback: "Done")
    /// Hide
    public static let hide = Localized.tr("Localizable", "common.hide", fallback: "Hide")
    /// %d ms
    public static func latencyInMs(_ p1: Int) -> String {
      return Localized.tr("Localizable", "common.latency_in_ms", p1, fallback: "%d ms")
    }
    /// Learn More
    public static let learnMore = Localized.tr("Localizable", "common.learn_more", fallback: "Learn More")
    /// Loading
    public static let loading = Localized.tr("Localizable", "common.loading", fallback: "Loading")
    /// Manage
    public static let manage = Localized.tr("Localizable", "common.manage", fallback: "Manage")
    /// Next
    public static let next = Localized.tr("Localizable", "common.next", fallback: "Next")
    /// No
    public static let no = Localized.tr("Localizable", "common.no", fallback: "No")
    /// No Results Found
    public static let noResultsFound = Localized.tr("Localizable", "common.no_results_found", fallback: "No Results Found")
    /// Not Available
    public static let notAvailable = Localized.tr("Localizable", "common.not_available", fallback: "Not Available")
    /// Open settings
    public static let openSettings = Localized.tr("Localizable", "common.open_settings", fallback: "Open settings")
    /// Paste
    public static let paste = Localized.tr("Localizable", "common.paste", fallback: "Paste")
    /// Phrase
    public static let phrase = Localized.tr("Localizable", "common.phrase", fallback: "Phrase")
    /// Pin
    public static let pin = Localized.tr("Localizable", "common.pin", fallback: "Pin")
    /// Pinned
    public static let pinned = Localized.tr("Localizable", "common.pinned", fallback: "Pinned")
    /// Popular
    public static let popular = Localized.tr("Localizable", "common.popular", fallback: "Popular")
    /// Private Key
    public static let privateKey = Localized.tr("Localizable", "common.private_key", fallback: "Private Key")
    /// Provider
    public static let provider = Localized.tr("Localizable", "common.provider", fallback: "Provider")
    /// Recommended
    public static let recommended = Localized.tr("Localizable", "common.recommended", fallback: "Recommended")
    /// %@ is required
    public static func requiredField(_ p1: Any) -> String {
      return Localized.tr("Localizable", "common.required_field", String(describing: p1), fallback: "%@ is required")
    }
    /// Secret Recovery Phrase
    public static let secretPhrase = Localized.tr("Localizable", "common.secret_phrase", fallback: "Secret Recovery Phrase")
    /// See All
    public static let seeAll = Localized.tr("Localizable", "common.see_all", fallback: "See All")
    /// Share
    public static let share = Localized.tr("Localizable", "common.share", fallback: "Share")
    /// Gem
    public static let shortName = Localized.tr("Localizable", "common.short_name", fallback: "Gem")
    /// Show %@
    public static func show(_ p1: Any) -> String {
      return Localized.tr("Localizable", "common.show", String(describing: p1), fallback: "Show %@")
    }
    /// Skip
    public static let skip = Localized.tr("Localizable", "common.skip", fallback: "Skip")
    /// Try Again
    public static let tryAgain = Localized.tr("Localizable", "common.try_again", fallback: "Try Again")
    /// Type
    public static let type = Localized.tr("Localizable", "common.type", fallback: "Type")
    /// Unpin
    public static let unpin = Localized.tr("Localizable", "common.unpin", fallback: "Unpin")
    /// URL
    public static let url = Localized.tr("Localizable", "common.url", fallback: "URL")
    /// Wallet
    public static let wallet = Localized.tr("Localizable", "common.wallet", fallback: "Wallet")
    /// Warning
    public static let warning = Localized.tr("Localizable", "common.warning", fallback: "Warning")
    /// Yes
    public static let yes = Localized.tr("Localizable", "common.yes", fallback: "Yes")
  }
  public enum Date {
    /// Today
    public static let today = Localized.tr("Localizable", "date.today", fallback: "Today")
    /// Yesterday
    public static let yesterday = Localized.tr("Localizable", "date.yesterday", fallback: "Yesterday")
  }
  public enum Errors {
    /// Camera permission not granted. Please enable camera access in settings to scan QR code.
    public static let cameraPermissionsNotGranted = Localized.tr("Localizable", "errors.camera_permissions_not_granted", fallback: "Camera permission not granted. Please enable camera access in settings to scan QR code.")
    /// Create Wallet Error: %s
    public static func createWallet(_ p1: UnsafePointer<CChar>) -> String {
      return Localized.tr("Localizable", "errors.create_wallet", p1, fallback: "Create Wallet Error: %s")
    }
    /// Decoding Error
    public static let decoding = Localized.tr("Localizable", "errors.decoding", fallback: "Decoding Error")
    /// Failed to decode the QR code. Please try again with a different QR code.
    public static let decodingQr = Localized.tr("Localizable", "errors.decoding_qr", fallback: "Failed to decode the QR code. Please try again with a different QR code.")
    /// The transaction failed because the amount is too small to meet the %@ network’s minimum requirement (dust threshold). This limit ensures the transaction value covers the fees and processing costs. Increase the amount or reduce the fees to proceed.
    public static func dustThreshold(_ p1: Any) -> String {
      return Localized.tr("Localizable", "errors.dust_threshold", String(describing: p1), fallback: "The transaction failed because the amount is too small to meet the %@ network’s minimum requirement (dust threshold). This limit ensures the transaction value covers the fees and processing costs. Increase the amount or reduce the fees to proceed.")
    }
    /// Error
    public static let error = Localized.tr("Localizable", "errors.error", fallback: "Error")
    /// An error occurred!
    public static let errorOccured = Localized.tr("Localizable", "errors.error_occured", fallback: "An error occurred!")
    /// Invalid address or name
    public static let invalidAddressName = Localized.tr("Localizable", "errors.invalid_address_name", fallback: "Invalid address or name")
    /// Invalid amount
    public static let invalidAmount = Localized.tr("Localizable", "errors.invalid_amount", fallback: "Invalid amount")
    /// Invalid %@ address
    public static func invalidAssetAddress(_ p1: Any) -> String {
      return Localized.tr("Localizable", "errors.invalid_asset_address", String(describing: p1), fallback: "Invalid %@ address")
    }
    /// Invalid Network ID
    public static let invalidNetworkId = Localized.tr("Localizable", "errors.invalid_network_id", fallback: "Invalid Network ID")
    /// Invalid URL
    public static let invalidUrl = Localized.tr("Localizable", "errors.invalid_url", fallback: "Invalid URL")
    /// Not Supported
    public static let notSupported = Localized.tr("Localizable", "errors.not_supported", fallback: "Not Supported")
    /// This device does not support QR code scanning. You can only select QR code image from library.
    public static let notSupportedQr = Localized.tr("Localizable", "errors.not_supported_qr", fallback: "This device does not support QR code scanning. You can only select QR code image from library.")
    /// Permissions Not Granted
    public static let permissionsNotGranted = Localized.tr("Localizable", "errors.permissions_not_granted", fallback: "Permissions Not Granted")
    /// Transfer Error: %s
    public static func transfer(_ p1: UnsafePointer<CChar>) -> String {
      return Localized.tr("Localizable", "errors.transfer", p1, fallback: "Transfer Error: %s")
    }
    /// Transfer Error
    public static let transferError = Localized.tr("Localizable", "errors.transfer_error", fallback: "Transfer Error")
    /// We are currently unable to calculate the network fee.
    public static let unableEstimateNetworkFee = Localized.tr("Localizable", "errors.unable_estimate_network_fee", fallback: "We are currently unable to calculate the network fee.")
    /// Unknown
    public static let unknown = Localized.tr("Localizable", "errors.unknown", fallback: "Unknown")
    /// An unknown error occurred. Please try again.
    public static let unknownTryAgain = Localized.tr("Localizable", "errors.unknown_try_again", fallback: "An unknown error occurred. Please try again.")
    /// Validation Error: %s
    public static func validation(_ p1: UnsafePointer<CChar>) -> String {
      return Localized.tr("Localizable", "errors.validation", p1, fallback: "Validation Error: %s")
    }
    public enum Connections {
      /// User cancelled
      public static let userCancelled = Localized.tr("Localizable", "errors.connections.user_cancelled", fallback: "User cancelled")
    }
    public enum Import {
      /// Invalid Secret Phrase
      public static let invalidSecretPhrase = Localized.tr("Localizable", "errors.import.invalid_secret_phrase", fallback: "Invalid Secret Phrase")
      /// Invalid Secret Phrase word: %@
      public static func invalidSecretPhraseWord(_ p1: Any) -> String {
        return Localized.tr("Localizable", "errors.import.invalid_secret_phrase_word", String(describing: p1), fallback: "Invalid Secret Phrase word: %@")
      }
    }
    public enum Swap {
      /// No quote available.
      public static let noQuoteAvailable = Localized.tr("Localizable", "errors.swap.no_quote_available", fallback: "No quote available.")
      /// No quote data
      public static let noQuoteData = Localized.tr("Localizable", "errors.swap.no_quote_data", fallback: "No quote data")
      /// Not supported asset.
      public static let notSupportedAsset = Localized.tr("Localizable", "errors.swap.not_supported_asset", fallback: "Not supported asset.")
      /// Not supported chain.
      public static let notSupportedChain = Localized.tr("Localizable", "errors.swap.not_supported_chain", fallback: "Not supported chain.")
      /// Not supported pair.
      public static let notSupportedPair = Localized.tr("Localizable", "errors.swap.not_supported_pair", fallback: "Not supported pair.")
    }
    public enum Token {
      /// Invalid Token ID
      public static let invalidId = Localized.tr("Localizable", "errors.token.invalid_id", fallback: "Invalid Token ID")
      /// Invalid token metadata
      public static let invalidMetadata = Localized.tr("Localizable", "errors.token.invalid_metadata", fallback: "Invalid token metadata")
      /// Unable to fetch token information: %@
      public static func unableFetchTokenInformation(_ p1: Any) -> String {
        return Localized.tr("Localizable", "errors.token.unable_fetch_token_information", String(describing: p1), fallback: "Unable to fetch token information: %@")
      }
    }
  }
  public enum FeeRate {
    /// %@ gwei
    public static func gwei(_ p1: Any) -> String {
      return Localized.tr("Localizable", "fee_rate.gwei", String(describing: p1), fallback: "%@ gwei")
    }
    /// %@ sat/B
    public static func satB(_ p1: Any) -> String {
      return Localized.tr("Localizable", "fee_rate.satB", String(describing: p1), fallback: "%@ sat/B")
    }
    /// %@ sat/vB
    public static func satvB(_ p1: Any) -> String {
      return Localized.tr("Localizable", "fee_rate.satvB", String(describing: p1), fallback: "%@ sat/vB")
    }
  }
  public enum FeeRates {
    /// Fast
    public static let fast = Localized.tr("Localizable", "fee_rates.fast", fallback: "Fast")
    /// Speed of transaction is determined by network fee paid to the network miners.
    public static let info = Localized.tr("Localizable", "fee_rates.info", fallback: "Speed of transaction is determined by network fee paid to the network miners.")
    /// Normal
    public static let normal = Localized.tr("Localizable", "fee_rates.normal", fallback: "Normal")
    /// Slow
    public static let slow = Localized.tr("Localizable", "fee_rates.slow", fallback: "Slow")
  }
  public enum Filter {
    /// Clear
    public static let clear = Localized.tr("Localizable", "filter.clear", fallback: "Clear")
    /// Filters
    public static let title = Localized.tr("Localizable", "filter.title", fallback: "Filters")
    /// Types
    public static let types = Localized.tr("Localizable", "filter.types", fallback: "Types")
  }
  public enum Info {
    public enum LockTime {
      /// Lock time, also known as the unbonding or unfreezing period, is the duration during which staked assets are inaccessible after you decide to unstake them.
      public static let description = Localized.tr("Localizable", "info.lock_time.description", fallback: "Lock time, also known as the unbonding or unfreezing period, is the duration during which staked assets are inaccessible after you decide to unstake them.")
    }
    public enum NetworkFee {
      /// %@ network charges transaction fee, which varies based on network usage. Paid to miners to process your transaction.
      public static func description(_ p1: Any) -> String {
        return Localized.tr("Localizable", "info.network_fee.description", String(describing: p1), fallback: "%@ network charges transaction fee, which varies based on network usage. Paid to miners to process your transaction.")
      }
      /// Network Fee
      public static let title = Localized.tr("Localizable", "info.network_fee.title", fallback: "Network Fee")
    }
    public enum Transaction {
      public enum Error {
        /// The transaction could not be completed due to an error, such as insufficient funds, invalid input, or rejection by the network. Please review the details and try again.
        public static let description = Localized.tr("Localizable", "info.transaction.error.description", fallback: "The transaction could not be completed due to an error, such as insufficient funds, invalid input, or rejection by the network. Please review the details and try again.")
      }
      public enum Pending {
        /// The transaction has been submitted and is awaiting confirmation on the network. Processing times may vary. Please check back for updates.
        public static let description = Localized.tr("Localizable", "info.transaction.pending.description", fallback: "The transaction has been submitted and is awaiting confirmation on the network. Processing times may vary. Please check back for updates.")
      }
      public enum Success {
        /// The transaction has been completed and confirmed on the network. You can review the details to verify its status.
        public static let description = Localized.tr("Localizable", "info.transaction.success.description", fallback: "The transaction has been completed and confirmed on the network. You can review the details to verify its status.")
      }
    }
    public enum WatchWallet {
      /// A wallet that you do not have access to, but you can watch its transactions and movements.
      public static let description = Localized.tr("Localizable", "info.watch_wallet.description", fallback: "A wallet that you do not have access to, but you can watch its transactions and movements.")
      /// Watch Wallet
      public static let title = Localized.tr("Localizable", "info.watch_wallet.title", fallback: "Watch Wallet")
    }
  }
  public enum Input {
    /// Please enter amount to %@
    public static func enterAmountTo(_ p1: Any) -> String {
      return Localized.tr("Localizable", "input.enter_amount_to", String(describing: p1), fallback: "Please enter amount to %@")
    }
    /// transfer
    public static let transfer = Localized.tr("Localizable", "input.transfer", fallback: "transfer")
  }
  public enum Library {
    /// Select from Photo Library
    public static let selectFromPhotoLibrary = Localized.tr("Localizable", "library.select_from_photo_library", fallback: "Select from Photo Library")
  }
  public enum Lock {
    /// 15 minutes
    public static let fifteenMinutes = Localized.tr("Localizable", "lock.fifteen_minutes", fallback: "15 minutes")
    /// 5 minutes
    public static let fiveMinutes = Localized.tr("Localizable", "lock.five_minutes", fallback: "5 minutes")
    /// Immediately
    public static let immediately = Localized.tr("Localizable", "lock.immediately", fallback: "Immediately")
    /// 1 hour
    public static let oneHour = Localized.tr("Localizable", "lock.one_hour", fallback: "1 hour")
    /// 1 minute
    public static let oneMinute = Localized.tr("Localizable", "lock.one_minute", fallback: "1 minute")
    /// Privacy Lock
    public static let privacyLock = Localized.tr("Localizable", "lock.privacy_lock", fallback: "Privacy Lock")
    /// Require authentication
    public static let requireAuthentication = Localized.tr("Localizable", "lock.require_authentication", fallback: "Require authentication")
    /// 6 hours
    public static let sixHours = Localized.tr("Localizable", "lock.six_hours", fallback: "6 hours")
    /// Unlock
    public static let unlock = Localized.tr("Localizable", "lock.unlock", fallback: "Unlock")
  }
  public enum Nft {
    /// Collection
    public static let collection = Localized.tr("Localizable", "nft.collection", fallback: "Collection")
    /// Collections
    public static let collections = Localized.tr("Localizable", "nft.collections", fallback: "Collections")
    /// Description
    public static let description = Localized.tr("Localizable", "nft.description", fallback: "Description")
    /// Properties
    public static let properties = Localized.tr("Localizable", "nft.properties", fallback: "Properties")
    /// Save to Photos
    public static let saveToPhotos = Localized.tr("Localizable", "nft.save_to_photos", fallback: "Save to Photos")
    /// Your image has been saved to Photos!
    public static let successSavedToPhotos = Localized.tr("Localizable", "nft.success_saved_to_photos", fallback: "Your image has been saved to Photos!")
  }
  public enum Nodes {
    /// Gem Wallet Node
    public static let gemWalletNode = Localized.tr("Localizable", "nodes.gem_wallet_node", fallback: "Gem Wallet Node")
    public enum ImportNode {
      /// Chain ID
      public static let chainId = Localized.tr("Localizable", "nodes.import_node.chain_id", fallback: "Chain ID")
      /// In Sync
      public static let inSync = Localized.tr("Localizable", "nodes.import_node.in_sync", fallback: "In Sync")
      /// Latency
      public static let latency = Localized.tr("Localizable", "nodes.import_node.latency", fallback: "Latency")
      /// Latest Block
      public static let latestBlock = Localized.tr("Localizable", "nodes.import_node.latest_block", fallback: "Latest Block")
      /// Add node
      public static let title = Localized.tr("Localizable", "nodes.import_node.title", fallback: "Add node")
    }
  }
  public enum Permissions {
    /// Access Denied
    public static let accessDenied = Localized.tr("Localizable", "permissions.access_denied", fallback: "Access Denied")
    public enum Image {
      public enum PhotoAccess {
        public enum Denied {
          /// This app does not have permission to access your photo library. Please enable access in your device settings.
          public static let description = Localized.tr("Localizable", "permissions.image.photo_access.denied.description", fallback: "This app does not have permission to access your photo library. Please enable access in your device settings.")
        }
      }
    }
  }
  public enum PriceAlerts {
    /// Price alert disabled for %@
    public static func disabledFor(_ p1: Any) -> String {
      return Localized.tr("Localizable", "price_alerts.disabled_for", String(describing: p1), fallback: "Price alert disabled for %@")
    }
    /// Price alert enabled for %@
    public static func enabledFor(_ p1: Any) -> String {
      return Localized.tr("Localizable", "price_alerts.enabled_for", String(describing: p1), fallback: "Price alert enabled for %@")
    }
    /// Get notified when there’s a significant price change in your favorite crypto assets.
    public static let getNotifiedExplainMessage = Localized.tr("Localizable", "price_alerts.get_notified_explain_message", fallback: "Get notified when there’s a significant price change in your favorite crypto assets.")
    public enum EmptyState {
      /// No price alerts added yet.
      public static let message = Localized.tr("Localizable", "price_alerts.empty_state.message", fallback: "No price alerts added yet.")
    }
  }
  public enum Receive {
    /// Receive %s
    public static func title(_ p1: UnsafePointer<CChar>) -> String {
      return Localized.tr("Localizable", "receive.title", p1, fallback: "Receive %s")
    }
    /// Your Receiving Address
    public static let yourAddress = Localized.tr("Localizable", "receive.your_address", fallback: "Your Receiving Address")
  }
  public enum Rootcheck {
    /// Your device appears to have root access, which can significantly increase security risks. Using this app on a rooted device may expose your assets to unauthorized access and potential loss. For the safety of your funds, we strongly recommend using a non-rooted device.
    public static let body = Localized.tr("Localizable", "rootcheck.body", fallback: "Your device appears to have root access, which can significantly increase security risks. Using this app on a rooted device may expose your assets to unauthorized access and potential loss. For the safety of your funds, we strongly recommend using a non-rooted device.")
    /// Exit
    public static let exit = Localized.tr("Localizable", "rootcheck.exit", fallback: "Exit")
    /// Ignore
    public static let ignore = Localized.tr("Localizable", "rootcheck.ignore", fallback: "Ignore")
    /// Security Warning
    public static let securityAlert = Localized.tr("Localizable", "rootcheck.security_alert", fallback: "Security Warning")
  }
  public enum SecretPhrase {
    /// Save your Secret Phrase in a secure place 
    /// that only you control.
    public static let savePhraseSafely = Localized.tr("Localizable", "secret_phrase.save_phrase_safely", fallback: "Save your Secret Phrase in a secure place \nthat only you control.")
    public enum Confirm {
      public enum QuickTest {
        /// Complete this quick test to confirm you've saved everything correctly.
        public static let title = Localized.tr("Localizable", "secret_phrase.confirm.quick_test.title", fallback: "Complete this quick test to confirm you've saved everything correctly.")
      }
    }
    public enum DoNotShare {
      /// If someone has your secret phrase they will have full control of your wallet!
      public static let description = Localized.tr("Localizable", "secret_phrase.do_not_share.description", fallback: "If someone has your secret phrase they will have full control of your wallet!")
      /// Do not share your Secret Phrase!
      public static let title = Localized.tr("Localizable", "secret_phrase.do_not_share.title", fallback: "Do not share your Secret Phrase!")
    }
  }
  public enum Sell {
    /// Sell %s
    public static func title(_ p1: UnsafePointer<CChar>) -> String {
      return Localized.tr("Localizable", "sell.title", p1, fallback: "Sell %s")
    }
  }
  public enum Settings {
    /// About Us
    public static let aboutus = Localized.tr("Localizable", "settings.aboutus", fallback: "About Us")
    /// Community
    public static let community = Localized.tr("Localizable", "settings.community", fallback: "Community")
    /// Currency
    public static let currency = Localized.tr("Localizable", "settings.currency", fallback: "Currency")
    /// Developer
    public static let developer = Localized.tr("Localizable", "settings.developer", fallback: "Developer")
    /// Enable Passcode
    public static let enablePasscode = Localized.tr("Localizable", "settings.enable_passcode", fallback: "Enable Passcode")
    /// Enable %@
    public static func enableValue(_ p1: Any) -> String {
      return Localized.tr("Localizable", "settings.enable_value", String(describing: p1), fallback: "Enable %@")
    }
    /// Help Center
    public static let helpCenter = Localized.tr("Localizable", "settings.help_center", fallback: "Help Center")
    /// Hide Balance
    public static let hideBalance = Localized.tr("Localizable", "settings.hide_balance", fallback: "Hide Balance")
    /// Language
    public static let language = Localized.tr("Localizable", "settings.language", fallback: "Language")
    /// Privacy Policy
    public static let privacyPolicy = Localized.tr("Localizable", "settings.privacy_policy", fallback: "Privacy Policy")
    /// Rate App
    public static let rateApp = Localized.tr("Localizable", "settings.rate_app", fallback: "Rate App")
    /// Security
    public static let security = Localized.tr("Localizable", "settings.security", fallback: "Security")
    /// Support
    public static let support = Localized.tr("Localizable", "settings.support", fallback: "Support")
    /// Terms of Services
    public static let termsOfServices = Localized.tr("Localizable", "settings.terms_of_services", fallback: "Terms of Services")
    /// Settings
    public static let title = Localized.tr("Localizable", "settings.title", fallback: "Settings")
    /// Version
    public static let version = Localized.tr("Localizable", "settings.version", fallback: "Version")
    /// Visit Website
    public static let website = Localized.tr("Localizable", "settings.website", fallback: "Visit Website")
    public enum Networks {
      /// Explorer
      public static let explorer = Localized.tr("Localizable", "settings.networks.explorer", fallback: "Explorer")
      /// Source
      public static let source = Localized.tr("Localizable", "settings.networks.source", fallback: "Source")
      /// Networks
      public static let title = Localized.tr("Localizable", "settings.networks.title", fallback: "Networks")
    }
    public enum Notifications {
      /// Notifications
      public static let title = Localized.tr("Localizable", "settings.notifications.title", fallback: "Notifications")
    }
    public enum PriceAlerts {
      /// Price Alerts
      public static let title = Localized.tr("Localizable", "settings.price_alerts.title", fallback: "Price Alerts")
    }
    public enum Security {
      /// Authentication
      public static let authentication = Localized.tr("Localizable", "settings.security.authentication", fallback: "Authentication")
    }
  }
  public enum SignMessage {
    /// Message
    public static let message = Localized.tr("Localizable", "sign_message.message", fallback: "Message")
    /// Sign Message
    public static let title = Localized.tr("Localizable", "sign_message.title", fallback: "Sign Message")
  }
  public enum Social {
    /// CoinGecko
    public static let coingecko = Localized.tr("Localizable", "social.coingecko", fallback: "CoinGecko")
    /// Discord
    public static let discord = Localized.tr("Localizable", "social.discord", fallback: "Discord")
    /// Facebook
    public static let facebook = Localized.tr("Localizable", "social.facebook", fallback: "Facebook")
    /// GitHub
    public static let github = Localized.tr("Localizable", "social.github", fallback: "GitHub")
    /// Links
    public static let links = Localized.tr("Localizable", "social.links", fallback: "Links")
    /// Reddit
    public static let reddit = Localized.tr("Localizable", "social.reddit", fallback: "Reddit")
    /// Telegram
    public static let telegram = Localized.tr("Localizable", "social.telegram", fallback: "Telegram")
    /// Website
    public static let website = Localized.tr("Localizable", "social.website", fallback: "Website")
    /// X (formerly Twitter)
    public static let x = Localized.tr("Localizable", "social.x", fallback: "X (formerly Twitter)")
    /// YouTube
    public static let youtube = Localized.tr("Localizable", "social.youtube", fallback: "YouTube")
  }
  public enum Stake {
    /// Activating
    public static let activating = Localized.tr("Localizable", "stake.activating", fallback: "Activating")
    /// Active
    public static let active = Localized.tr("Localizable", "stake.active", fallback: "Active")
    /// Active In
    public static let activeIn = Localized.tr("Localizable", "stake.active_in", fallback: "Active In")
    /// APR %@
    public static func apr(_ p1: Any) -> String {
      return Localized.tr("Localizable", "stake.apr", String(describing: p1), fallback: "APR %@")
    }
    /// Available In
    public static let availableIn = Localized.tr("Localizable", "stake.available_in", fallback: "Available In")
    /// Awaiting Withdrawal
    public static let awaitingWithdrawal = Localized.tr("Localizable", "stake.awaiting_withdrawal", fallback: "Awaiting Withdrawal")
    /// Deactivating
    public static let deactivating = Localized.tr("Localizable", "stake.deactivating", fallback: "Deactivating")
    /// Inactive
    public static let inactive = Localized.tr("Localizable", "stake.inactive", fallback: "Inactive")
    /// Lock Time
    public static let lockTime = Localized.tr("Localizable", "stake.lock_time", fallback: "Lock Time")
    /// Minimum amount
    public static let minimumAmount = Localized.tr("Localizable", "stake.minimum_amount", fallback: "Minimum amount")
    /// No active staking yet.
    public static let noActiveStaking = Localized.tr("Localizable", "stake.no_active_staking", fallback: "No active staking yet.")
    /// Pending
    public static let pending = Localized.tr("Localizable", "stake.pending", fallback: "Pending")
    /// Rewards
    public static let rewards = Localized.tr("Localizable", "stake.rewards", fallback: "Rewards")
    /// Stake
    public static let stake = Localized.tr("Localizable", "stake.stake", fallback: "Stake")
    /// Validator
    public static let validator = Localized.tr("Localizable", "stake.validator", fallback: "Validator")
    /// Validators
    public static let validators = Localized.tr("Localizable", "stake.validators", fallback: "Validators")
    /// Stake via Gem Wallet
    public static let viagem = Localized.tr("Localizable", "stake.viagem", fallback: "Stake via Gem Wallet")
  }
  public enum Swap {
    /// Approve %@ to Swap
    public static func approveToken(_ p1: Any) -> String {
      return Localized.tr("Localizable", "swap.approve_token", String(describing: p1), fallback: "Approve %@ to Swap")
    }
    /// Approve %@ token for swap access.
    public static func approveTokenPermission(_ p1: Any) -> String {
      return Localized.tr("Localizable", "swap.approve_token_permission", String(describing: p1), fallback: "Approve %@ token for swap access.")
    }
    /// Price Impact
    public static let priceImpact = Localized.tr("Localizable", "swap.price_impact", fallback: "Price Impact")
    /// Provider
    public static let provider = Localized.tr("Localizable", "swap.provider", fallback: "Provider")
    /// Quote includes a %@ Gem fee.
    public static func quoteFee(_ p1: Any) -> String {
      return Localized.tr("Localizable", "swap.quote_fee", String(describing: p1), fallback: "Quote includes a %@ Gem fee.")
    }
    /// Slippage
    public static let slippage = Localized.tr("Localizable", "swap.slippage", fallback: "Slippage")
    /// You Pay
    public static let youPay = Localized.tr("Localizable", "swap.you_pay", fallback: "You Pay")
    /// You Receive
    public static let youReceive = Localized.tr("Localizable", "swap.you_receive", fallback: "You Receive")
  }
  public enum Transaction {
    /// Date
    public static let date = Localized.tr("Localizable", "transaction.date", fallback: "Date")
    /// Recipient
    public static let recipient = Localized.tr("Localizable", "transaction.recipient", fallback: "Recipient")
    /// Sender
    public static let sender = Localized.tr("Localizable", "transaction.sender", fallback: "Sender")
    /// Status
    public static let status = Localized.tr("Localizable", "transaction.status", fallback: "Status")
    /// View on %@
    public static func viewOn(_ p1: Any) -> String {
      return Localized.tr("Localizable", "transaction.view_on", String(describing: p1), fallback: "View on %@")
    }
    public enum Status {
      /// Successful
      public static let confirmed = Localized.tr("Localizable", "transaction.status.confirmed", fallback: "Successful")
      /// Failed
      public static let failed = Localized.tr("Localizable", "transaction.status.failed", fallback: "Failed")
      /// Pending
      public static let pending = Localized.tr("Localizable", "transaction.status.pending", fallback: "Pending")
      /// Reverted
      public static let reverted = Localized.tr("Localizable", "transaction.status.reverted", fallback: "Reverted")
    }
    public enum Title {
      /// Received
      public static let received = Localized.tr("Localizable", "transaction.title.received", fallback: "Received")
      /// Sent
      public static let sent = Localized.tr("Localizable", "transaction.title.sent", fallback: "Sent")
    }
  }
  public enum Transfer {
    /// Address
    public static let address = Localized.tr("Localizable", "transfer.address", fallback: "Address")
    /// Amount
    public static let amount = Localized.tr("Localizable", "transfer.amount", fallback: "Amount")
    /// Balance: %@
    public static func balance(_ p1: Any) -> String {
      return Localized.tr("Localizable", "transfer.balance", String(describing: p1), fallback: "Balance: %@")
    }
    /// Confirm
    public static let confirm = Localized.tr("Localizable", "transfer.confirm", fallback: "Confirm")
    /// From
    public static let from = Localized.tr("Localizable", "transfer.from", fallback: "From")
    /// Insufficient %@ balance.
    public static func insufficientBalance(_ p1: Any) -> String {
      return Localized.tr("Localizable", "transfer.insufficient_balance", String(describing: p1), fallback: "Insufficient %@ balance.")
    }
    /// Insufficient %@ balance to cover network fees.
    public static func insufficientNetworkFeeBalance(_ p1: Any) -> String {
      return Localized.tr("Localizable", "transfer.insufficient_network_fee_balance", String(describing: p1), fallback: "Insufficient %@ balance to cover network fees.")
    }
    /// Max
    public static let max = Localized.tr("Localizable", "transfer.max", fallback: "Max")
    /// Memo
    public static let memo = Localized.tr("Localizable", "transfer.memo", fallback: "Memo")
    /// Minimum Amount is %@
    public static func minimumAmount(_ p1: Any) -> String {
      return Localized.tr("Localizable", "transfer.minimum_amount", String(describing: p1), fallback: "Minimum Amount is %@")
    }
    /// Network
    public static let network = Localized.tr("Localizable", "transfer.network", fallback: "Network")
    /// Network Fee
    public static let networkFee = Localized.tr("Localizable", "transfer.network_fee", fallback: "Network Fee")
    /// Step %d
    public static func step(_ p1: Int) -> String {
      return Localized.tr("Localizable", "transfer.step", p1, fallback: "Step %d")
    }
    /// Transfer
    public static let title = Localized.tr("Localizable", "transfer.title", fallback: "Transfer")
    /// To
    public static let to = Localized.tr("Localizable", "transfer.to", fallback: "To")
    public enum ActivateAsset {
      /// Activate Asset
      public static let title = Localized.tr("Localizable", "transfer.activate_asset.title", fallback: "Activate Asset")
    }
    public enum Amount {
      /// Amount
      public static let title = Localized.tr("Localizable", "transfer.amount.title", fallback: "Amount")
    }
    public enum Approve {
      /// Approve
      public static let title = Localized.tr("Localizable", "transfer.approve.title", fallback: "Approve")
    }
    public enum ClaimRewards {
      /// Claim Rewards
      public static let title = Localized.tr("Localizable", "transfer.claim_rewards.title", fallback: "Claim Rewards")
    }
    public enum Confirm {
      /// Max total
      public static let maxtotal = Localized.tr("Localizable", "transfer.confirm.maxtotal", fallback: "Max total")
    }
    public enum Recipient {
      /// Address or Name
      public static let addressField = Localized.tr("Localizable", "transfer.recipient.address_field", fallback: "Address or Name")
      /// Recipient
      public static let title = Localized.tr("Localizable", "transfer.recipient.title", fallback: "Recipient")
    }
    public enum Redelegate {
      /// Redelegate
      public static let title = Localized.tr("Localizable", "transfer.redelegate.title", fallback: "Redelegate")
    }
    public enum Rewards {
      /// Rewards
      public static let title = Localized.tr("Localizable", "transfer.rewards.title", fallback: "Rewards")
    }
    public enum Send {
      /// Send
      public static let title = Localized.tr("Localizable", "transfer.send.title", fallback: "Send")
    }
    public enum Stake {
      /// Stake
      public static let title = Localized.tr("Localizable", "transfer.stake.title", fallback: "Stake")
    }
    public enum Unstake {
      /// Unstake
      public static let title = Localized.tr("Localizable", "transfer.unstake.title", fallback: "Unstake")
    }
    public enum Withdraw {
      /// Withdraw
      public static let title = Localized.tr("Localizable", "transfer.withdraw.title", fallback: "Withdraw")
    }
  }
  public enum UpdateApp {
    /// Update
    public static let action = Localized.tr("Localizable", "update_app.action", fallback: "Update")
    /// Version %@ of the app is now available. Update and enjoy the latest features and improvements.
    public static func description(_ p1: Any) -> String {
      return Localized.tr("Localizable", "update_app.description", String(describing: p1), fallback: "Version %@ of the app is now available. Update and enjoy the latest features and improvements.")
    }
    /// New update available!
    public static let title = Localized.tr("Localizable", "update_app.title", fallback: "New update available!")
  }
  public enum VerifyPhrase {
    /// Confirm
    public static let title = Localized.tr("Localizable", "verify_phrase.title", fallback: "Confirm")
  }
  public enum Wallet {
    /// Buy
    public static let buy = Localized.tr("Localizable", "wallet.buy", fallback: "Buy")
    /// Copy Address
    public static let copyAddress = Localized.tr("Localizable", "wallet.copy_address", fallback: "Copy Address")
    /// Create a New Wallet
    public static let createNewWallet = Localized.tr("Localizable", "wallet.create_new_wallet", fallback: "Create a New Wallet")
    /// Wallet #%d
    public static func defaultName(_ p1: Int) -> String {
      return Localized.tr("Localizable", "wallet.default_name", p1, fallback: "Wallet #%d")
    }
    /// %@ Wallet #%d
    public static func defaultNameChain(_ p1: Any, _ p2: Int) -> String {
      return Localized.tr("Localizable", "wallet.default_name_chain", String(describing: p1), p2, fallback: "%@ Wallet #%d")
    }
    /// Import an Existing Wallet
    public static let importExistingWallet = Localized.tr("Localizable", "wallet.import_existing_wallet", fallback: "Import an Existing Wallet")
    /// Manage Token List
    public static let manageTokenList = Localized.tr("Localizable", "wallet.manage_token_list", fallback: "Manage Token List")
    /// More
    public static let more = Localized.tr("Localizable", "wallet.more", fallback: "More")
    /// Multi-Coin
    public static let multicoin = Localized.tr("Localizable", "wallet.multicoin", fallback: "Multi-Coin")
    /// Name
    public static let name = Localized.tr("Localizable", "wallet.name", fallback: "Name")
    /// Receive
    public static let receive = Localized.tr("Localizable", "wallet.receive", fallback: "Receive")
    /// Receive Collection
    public static let receiveCollection = Localized.tr("Localizable", "wallet.receive_collection", fallback: "Receive Collection")
    /// Scan
    public static let scan = Localized.tr("Localizable", "wallet.scan", fallback: "Scan")
    /// Scan QR Code
    public static let scanQrCode = Localized.tr("Localizable", "wallet.scan_qr_code", fallback: "Scan QR Code")
    /// Sell
    public static let sell = Localized.tr("Localizable", "wallet.sell", fallback: "Sell")
    /// Send
    public static let send = Localized.tr("Localizable", "wallet.send", fallback: "Send")
    /// Stake
    public static let stake = Localized.tr("Localizable", "wallet.stake", fallback: "Stake")
    /// Swap
    public static let swap = Localized.tr("Localizable", "wallet.swap", fallback: "Swap")
    /// Wallet
    public static let title = Localized.tr("Localizable", "wallet.title", fallback: "Wallet")
    public enum AddToken {
      /// Add Token
      public static let title = Localized.tr("Localizable", "wallet.add_token.title", fallback: "Add Token")
    }
    public enum Import {
      /// Import
      public static let action = Localized.tr("Localizable", "wallet.import.action", fallback: "Import")
      /// Address or Name
      public static let addressField = Localized.tr("Localizable", "wallet.import.address_field", fallback: "Address or Name")
      /// Contract Address or Token ID
      public static let contractAddressField = Localized.tr("Localizable", "wallet.import.contract_address_field", fallback: "Contract Address or Token ID")
      /// %@ encoded private key
      public static func privateKey(_ p1: Any) -> String {
        return Localized.tr("Localizable", "wallet.import.private_key", String(describing: p1), fallback: "%@ encoded private key")
      }
      /// Secret Recovery Phrase
      public static let secretPhrase = Localized.tr("Localizable", "wallet.import.secret_phrase", fallback: "Secret Recovery Phrase")
      /// Import Wallet
      public static let title = Localized.tr("Localizable", "wallet.import.title", fallback: "Import Wallet")
    }
    public enum New {
      /// Confirm that you've written down and stored your Secret Recovery Phrase securely before proceeding, as it is crucial for future wallet access and recovery.
      public static let backupConfirmWarning = Localized.tr("Localizable", "wallet.new.backup_confirm_warning", fallback: "Confirm that you've written down and stored your Secret Recovery Phrase securely before proceeding, as it is crucial for future wallet access and recovery.")
      /// Write down your unique Secret Recovery Phrase and store it securely; it's essential for wallet access and recovery.
      public static let backupWarning = Localized.tr("Localizable", "wallet.new.backup_warning", fallback: "Write down your unique Secret Recovery Phrase and store it securely; it's essential for wallet access and recovery.")
      /// New Wallet
      public static let title = Localized.tr("Localizable", "wallet.new.title", fallback: "New Wallet")
    }
    public enum Receive {
      /// No destination tag required
      public static let noDestinationTagRequired = Localized.tr("Localizable", "wallet.receive.no_destination_tag_required", fallback: "No destination tag required")
      /// No memo required
      public static let noMemoRequired = Localized.tr("Localizable", "wallet.receive.no_memo_required", fallback: "No memo required")
    }
    public enum Watch {
      public enum Tooltip {
        /// You are watching this wallet.
        public static let title = Localized.tr("Localizable", "wallet.watch.tooltip.title", fallback: "You are watching this wallet.")
      }
    }
  }
  public enum WalletConnect {
    /// App
    public static let app = Localized.tr("Localizable", "wallet_connect.app", fallback: "App")
    /// WalletConnect
    public static let brandName = Localized.tr("Localizable", "wallet_connect.brand_name", fallback: "WalletConnect")
    /// Disconnect
    public static let disconnect = Localized.tr("Localizable", "wallet_connect.disconnect", fallback: "Disconnect")
    /// No active connections
    public static let noActiveConnections = Localized.tr("Localizable", "wallet_connect.no_active_connections", fallback: "No active connections")
    /// WalletConnect
    public static let title = Localized.tr("Localizable", "wallet_connect.title", fallback: "WalletConnect")
    /// Website
    public static let website = Localized.tr("Localizable", "wallet_connect.website", fallback: "Website")
    public enum Connect {
      /// Connect
      public static let title = Localized.tr("Localizable", "wallet_connect.connect.title", fallback: "Connect")
    }
    public enum Connection {
      /// Connection
      public static let title = Localized.tr("Localizable", "wallet_connect.connection.title", fallback: "Connection")
    }
  }
  public enum Wallets {
    /// Wallets
    public static let title = Localized.tr("Localizable", "wallets.title", fallback: "Wallets")
    /// Watch
    public static let watch = Localized.tr("Localizable", "wallets.watch", fallback: "Watch")
  }
  public enum Warnings {
    /// Do not transfer funds to this %@ Multi-Signature wallet unless you are certain you control the private keys. Failure to do so could expose you to scams, and you may permanently lose your assets.
    public static func multiSignatureBlocked(_ p1: Any) -> String {
      return Localized.tr("Localizable", "warnings.multi_signature_blocked", String(describing: p1), fallback: "Do not transfer funds to this %@ Multi-Signature wallet unless you are certain you control the private keys. Failure to do so could expose you to scams, and you may permanently lose your assets.")
    }
  }
  public enum Welcome {
    /// Welcome to Gem Family
    public static let title = Localized.tr("Localizable", "welcome.title", fallback: "Welcome to Gem Family")
    public enum Legal {
      /// By using Gem, you agree to accept our
      ///  [Terms of Use](%s) and [Privacy Policy](%s)
      public static func concent(_ p1: UnsafePointer<CChar>, _ p2: UnsafePointer<CChar>) -> String {
        return Localized.tr("Localizable", "welcome.legal.concent", p1, p2, fallback: "By using Gem, you agree to accept our\n [Terms of Use](%s) and [Privacy Policy](%s)")
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension Localized {
  private static func tr(_ table: String, _ key: String, _ args: any CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
