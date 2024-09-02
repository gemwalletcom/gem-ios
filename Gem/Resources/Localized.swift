// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum Localized {
  internal enum Activity {
    /// Activity
    internal static let title = Localized.tr("Localizable", "activity.title", fallback: "Activity")
    internal enum EmptyState {
      /// No activity yet.
      internal static let message = Localized.tr("Localizable", "activity.empty_state.message", fallback: "No activity yet.")
    }
  }
  internal enum App {
    /// Gem
    internal static let name = Localized.tr("Localizable", "app.name", fallback: "Gem")
  }
  internal enum Asset {
    /// Balances
    internal static let balances = Localized.tr("Localizable", "asset.balances", fallback: "Balances")
    /// Circulating Supply
    internal static let circulatingSupply = Localized.tr("Localizable", "asset.circulating_supply", fallback: "Circulating Supply")
    /// Decimals
    internal static let decimals = Localized.tr("Localizable", "asset.decimals", fallback: "Decimals")
    /// Latest Transactions
    internal static let latestTransactions = Localized.tr("Localizable", "asset.latest_transactions", fallback: "Latest Transactions")
    /// Market Cap
    internal static let marketCap = Localized.tr("Localizable", "asset.market_cap", fallback: "Market Cap")
    /// Market Cap Rank
    internal static let marketCapRank = Localized.tr("Localizable", "asset.market_cap_rank", fallback: "Market Cap Rank")
    /// Name
    internal static let name = Localized.tr("Localizable", "asset.name", fallback: "Name")
    /// Price
    internal static let price = Localized.tr("Localizable", "asset.price", fallback: "Price")
    /// Symbol
    internal static let symbol = Localized.tr("Localizable", "asset.symbol", fallback: "Symbol")
    /// Token ID
    internal static let tokenId = Localized.tr("Localizable", "asset.token_id", fallback: "Token ID")
    /// Total Supply
    internal static let totalSupply = Localized.tr("Localizable", "asset.total_supply", fallback: "Total Supply")
    /// Trading Volume (24h)
    internal static let tradingVolume = Localized.tr("Localizable", "asset.trading_volume", fallback: "Trading Volume (24h)")
    /// View address on %@
    internal static func viewAddressOn(_ p1: Any) -> String {
      return Localized.tr("Localizable", "asset.view_address_on", String(describing: p1), fallback: "View address on %@")
    }
    /// View token on %@
    internal static func viewTokenOn(_ p1: Any) -> String {
      return Localized.tr("Localizable", "asset.view_token_on", String(describing: p1), fallback: "View token on %@")
    }
    internal enum Balances {
      /// Available
      internal static let available = Localized.tr("Localizable", "asset.balances.available", fallback: "Available")
      /// Reserved
      internal static let reserved = Localized.tr("Localizable", "asset.balances.reserved", fallback: "Reserved")
    }
  }
  internal enum Assets {
    /// Add Custom Token
    internal static let addCustomToken = Localized.tr("Localizable", "assets.add_custom_token", fallback: "Add Custom Token")
    /// Hidden
    internal static let hidden = Localized.tr("Localizable", "assets.hidden", fallback: "Hidden")
    /// No assets found
    internal static let noAssetsFound = Localized.tr("Localizable", "assets.no_assets_found", fallback: "No assets found")
  }
  internal enum Banner {
    internal enum AccountActivation {
      /// The %@ network requires a one time fee of %@.
      internal static func description(_ p1: Any, _ p2: Any) -> String {
        return Localized.tr("Localizable", "banner.account_activation.description", String(describing: p1), String(describing: p2), fallback: "The %@ network requires a one time fee of %@.")
      }
      /// %@ Account Activation Fee
      internal static func title(_ p1: Any) -> String {
        return Localized.tr("Localizable", "banner.account_activation.title", String(describing: p1), fallback: "%@ Account Activation Fee")
      }
    }
    internal enum EnableNotifications {
      /// Stay on top of your wallet activity.
      internal static let description = Localized.tr("Localizable", "banner.enable_notifications.description", fallback: "Stay on top of your wallet activity.")
      /// Enable Notifications
      internal static let title = Localized.tr("Localizable", "banner.enable_notifications.title", fallback: "Enable Notifications")
    }
    internal enum Stake {
      /// Earn %@ rewards on your stake while you sleep.
      internal static func description(_ p1: Any) -> String {
        return Localized.tr("Localizable", "banner.stake.description", String(describing: p1), fallback: "Earn %@ rewards on your stake while you sleep.")
      }
      /// Start staking %@
      internal static func title(_ p1: Any) -> String {
        return Localized.tr("Localizable", "banner.stake.title", String(describing: p1), fallback: "Start staking %@")
      }
    }
  }
  internal enum Buy {
    /// Please enter amount to buy
    internal static let emptyAmount = Localized.tr("Localizable", "buy.empty_amount", fallback: "Please enter amount to buy")
    /// No quotes available
    internal static let noResults = Localized.tr("Localizable", "buy.no_results", fallback: "No quotes available")
    /// Rate
    internal static let rate = Localized.tr("Localizable", "buy.rate", fallback: "Rate")
    /// Buy %s
    internal static func title(_ p1: UnsafePointer<CChar>) -> String {
      return Localized.tr("Localizable", "buy.title", p1, fallback: "Buy %s")
    }
    internal enum Providers {
      /// Providers
      internal static let title = Localized.tr("Localizable", "buy.providers.title", fallback: "Providers")
    }
  }
  internal enum Charts {
    /// All
    internal static let all = Localized.tr("Localizable", "charts.all", fallback: "All")
    /// 1D
    internal static let day = Localized.tr("Localizable", "charts.day", fallback: "1D")
    /// 1H
    internal static let hour = Localized.tr("Localizable", "charts.hour", fallback: "1H")
    /// 1M
    internal static let month = Localized.tr("Localizable", "charts.month", fallback: "1M")
    /// 1W
    internal static let week = Localized.tr("Localizable", "charts.week", fallback: "1W")
    /// 1Y
    internal static let year = Localized.tr("Localizable", "charts.year", fallback: "1Y")
  }
  internal enum Common {
    /// Address
    internal static let address = Localized.tr("Localizable", "common.address", fallback: "Address")
    /// All
    internal static let all = Localized.tr("Localizable", "common.all", fallback: "All")
    /// Back
    internal static let back = Localized.tr("Localizable", "common.back", fallback: "Back")
    /// Cancel
    internal static let cancel = Localized.tr("Localizable", "common.cancel", fallback: "Cancel")
    /// Continue
    internal static let `continue` = Localized.tr("Localizable", "common.continue", fallback: "Continue")
    /// Copied: %@
    internal static func copied(_ p1: Any) -> String {
      return Localized.tr("Localizable", "common.copied", String(describing: p1), fallback: "Copied: %@")
    }
    /// Copy
    internal static let copy = Localized.tr("Localizable", "common.copy", fallback: "Copy")
    /// Delete
    internal static let delete = Localized.tr("Localizable", "common.delete", fallback: "Delete")
    /// Are sure you want to delete %s?
    internal static func deleteConfirmation(_ p1: UnsafePointer<CChar>) -> String {
      return Localized.tr("Localizable", "common.delete_confirmation", p1, fallback: "Are sure you want to delete %s?")
    }
    /// Done
    internal static let done = Localized.tr("Localizable", "common.done", fallback: "Done")
    /// Hide
    internal static let hide = Localized.tr("Localizable", "common.hide", fallback: "Hide")
    /// %d ms
    internal static func latencyInMs(_ p1: Int) -> String {
      return Localized.tr("Localizable", "common.latency_in_ms", p1, fallback: "%d ms")
    }
    /// Loading
    internal static let loading = Localized.tr("Localizable", "common.loading", fallback: "Loading")
    /// Manage
    internal static let manage = Localized.tr("Localizable", "common.manage", fallback: "Manage")
    /// Next
    internal static let next = Localized.tr("Localizable", "common.next", fallback: "Next")
    /// No
    internal static let no = Localized.tr("Localizable", "common.no", fallback: "No")
    /// No Results Found
    internal static let noResultsFound = Localized.tr("Localizable", "common.no_results_found", fallback: "No Results Found")
    /// Not Available
    internal static let notAvailable = Localized.tr("Localizable", "common.not_available", fallback: "Not Available")
    /// Open settings
    internal static let openSettings = Localized.tr("Localizable", "common.open_settings", fallback: "Open settings")
    /// Paste
    internal static let paste = Localized.tr("Localizable", "common.paste", fallback: "Paste")
    /// Phrase
    internal static let phrase = Localized.tr("Localizable", "common.phrase", fallback: "Phrase")
    /// Pin
    internal static let pin = Localized.tr("Localizable", "common.pin", fallback: "Pin")
    /// Pinned
    internal static let pinned = Localized.tr("Localizable", "common.pinned", fallback: "Pinned")
    /// Private Key
    internal static let privateKey = Localized.tr("Localizable", "common.private_key", fallback: "Private Key")
    /// Provider
    internal static let provider = Localized.tr("Localizable", "common.provider", fallback: "Provider")
    /// Recommended
    internal static let recommended = Localized.tr("Localizable", "common.recommended", fallback: "Recommended")
    /// %@ is required
    internal static func requiredField(_ p1: Any) -> String {
      return Localized.tr("Localizable", "common.required_field", String(describing: p1), fallback: "%@ is required")
    }
    /// Secret Recovery Phrase
    internal static let secretPhrase = Localized.tr("Localizable", "common.secret_phrase", fallback: "Secret Recovery Phrase")
    /// See All
    internal static let seeAll = Localized.tr("Localizable", "common.see_all", fallback: "See All")
    /// Share
    internal static let share = Localized.tr("Localizable", "common.share", fallback: "Share")
    /// Show %@
    internal static func show(_ p1: Any) -> String {
      return Localized.tr("Localizable", "common.show", String(describing: p1), fallback: "Show %@")
    }
    /// Try Again
    internal static let tryAgain = Localized.tr("Localizable", "common.try_again", fallback: "Try Again")
    /// Type
    internal static let type = Localized.tr("Localizable", "common.type", fallback: "Type")
    /// Unpin
    internal static let unpin = Localized.tr("Localizable", "common.unpin", fallback: "Unpin")
    /// URL
    internal static let url = Localized.tr("Localizable", "common.url", fallback: "URL")
    /// Wallet
    internal static let wallet = Localized.tr("Localizable", "common.wallet", fallback: "Wallet")
    /// Yes
    internal static let yes = Localized.tr("Localizable", "common.yes", fallback: "Yes")
  }
  internal enum Date {
    /// Today
    internal static let today = Localized.tr("Localizable", "date.today", fallback: "Today")
    /// Yesterday
    internal static let yesterday = Localized.tr("Localizable", "date.yesterday", fallback: "Yesterday")
  }
  internal enum Errors {
    /// Camera permission not granted. Please enable camera access in settings to scan QR code.
    internal static let cameraPermissionsNotGranted = Localized.tr("Localizable", "errors.camera_permissions_not_granted", fallback: "Camera permission not granted. Please enable camera access in settings to scan QR code.")
    /// Create Wallet Error: %s
    internal static func createWallet(_ p1: UnsafePointer<CChar>) -> String {
      return Localized.tr("Localizable", "errors.create_wallet", p1, fallback: "Create Wallet Error: %s")
    }
    /// Decoding Error
    internal static let decoding = Localized.tr("Localizable", "errors.decoding", fallback: "Decoding Error")
    /// Failed to decode the QR code. Please try again with a different QR code.
    internal static let decodingQr = Localized.tr("Localizable", "errors.decoding_qr", fallback: "Failed to decode the QR code. Please try again with a different QR code.")
    /// Error
    internal static let error = Localized.tr("Localizable", "errors.error", fallback: "Error")
    /// An error occurred!
    internal static let errorOccured = Localized.tr("Localizable", "errors.error_occured", fallback: "An error occurred!")
    /// Invalid address or name
    internal static let invalidAddressName = Localized.tr("Localizable", "errors.invalid_address_name", fallback: "Invalid address or name")
    /// Invalid amount
    internal static let invalidAmount = Localized.tr("Localizable", "errors.invalid_amount", fallback: "Invalid amount")
    /// Invalid %@ address
    internal static func invalidAssetAddress(_ p1: Any) -> String {
      return Localized.tr("Localizable", "errors.invalid_asset_address", String(describing: p1), fallback: "Invalid %@ address")
    }
    /// Invalid Network ID
    internal static let invalidNetworkId = Localized.tr("Localizable", "errors.invalid_network_id", fallback: "Invalid Network ID")
    /// Invalid URL
    internal static let invalidUrl = Localized.tr("Localizable", "errors.invalid_url", fallback: "Invalid URL")
    /// Not Supported
    internal static let notSupported = Localized.tr("Localizable", "errors.not_supported", fallback: "Not Supported")
    /// This device does not support QR code scanning. You can only select QR code image from library.
    internal static let notSupportedQr = Localized.tr("Localizable", "errors.not_supported_qr", fallback: "This device does not support QR code scanning. You can only select QR code image from library.")
    /// Permissions Not Granted
    internal static let permissionsNotGranted = Localized.tr("Localizable", "errors.permissions_not_granted", fallback: "Permissions Not Granted")
    /// Transfer Error: %s
    internal static func transfer(_ p1: UnsafePointer<CChar>) -> String {
      return Localized.tr("Localizable", "errors.transfer", p1, fallback: "Transfer Error: %s")
    }
    /// Transfer Error
    internal static let transferError = Localized.tr("Localizable", "errors.transfer_error", fallback: "Transfer Error")
    /// We are currently unable to calculate the network fee.
    internal static let unableEstimateNetworkFee = Localized.tr("Localizable", "errors.unable_estimate_network_fee", fallback: "We are currently unable to calculate the network fee.")
    /// Unknown
    internal static let unknown = Localized.tr("Localizable", "errors.unknown", fallback: "Unknown")
    /// An unknown error occurred. Please try again.
    internal static let unknownTryAgain = Localized.tr("Localizable", "errors.unknown_try_again", fallback: "An unknown error occurred. Please try again.")
    /// Validation Error: %s
    internal static func validation(_ p1: UnsafePointer<CChar>) -> String {
      return Localized.tr("Localizable", "errors.validation", p1, fallback: "Validation Error: %s")
    }
    internal enum Connections {
      /// User cancelled
      internal static let userCancelled = Localized.tr("Localizable", "errors.connections.user_cancelled", fallback: "User cancelled")
    }
    internal enum Import {
      /// Invalid Secret Phrase
      internal static let invalidSecretPhrase = Localized.tr("Localizable", "errors.import.invalid_secret_phrase", fallback: "Invalid Secret Phrase")
      /// Invalid Secret Phrase word: %@
      internal static func invalidSecretPhraseWord(_ p1: Any) -> String {
        return Localized.tr("Localizable", "errors.import.invalid_secret_phrase_word", String(describing: p1), fallback: "Invalid Secret Phrase word: %@")
      }
    }
    internal enum Swap {
      /// No quote data
      internal static let noQuoteData = Localized.tr("Localizable", "errors.swap.no_quote_data", fallback: "No quote data")
    }
    internal enum Token {
      /// Invalid Token ID
      internal static let invalidId = Localized.tr("Localizable", "errors.token.invalid_id", fallback: "Invalid Token ID")
      /// Invalid token metadata
      internal static let invalidMetadata = Localized.tr("Localizable", "errors.token.invalid_metadata", fallback: "Invalid token metadata")
      /// Unable to fetch token information: %@
      internal static func unableFetchTokenInformation(_ p1: Any) -> String {
        return Localized.tr("Localizable", "errors.token.unable_fetch_token_information", String(describing: p1), fallback: "Unable to fetch token information: %@")
      }
    }
  }
  internal enum FeeRate {
    /// %@ sat/B
    internal static func satB(_ p1: Any) -> String {
      return Localized.tr("Localizable", "fee_rate.satB", String(describing: p1), fallback: "%@ sat/B")
    }
    /// %@ sat/vB
    internal static func satvB(_ p1: Any) -> String {
      return Localized.tr("Localizable", "fee_rate.satvB", String(describing: p1), fallback: "%@ sat/vB")
    }
  }
  internal enum FeeRates {
    /// Fast
    internal static let fast = Localized.tr("Localizable", "fee_rates.fast", fallback: "Fast")
    /// Speed of transaction is determined by network fee paid to the network miners.
    internal static let info = Localized.tr("Localizable", "fee_rates.info", fallback: "Speed of transaction is determined by network fee paid to the network miners.")
    /// Normal
    internal static let normal = Localized.tr("Localizable", "fee_rates.normal", fallback: "Normal")
    /// Slow
    internal static let slow = Localized.tr("Localizable", "fee_rates.slow", fallback: "Slow")
  }
  internal enum Filter {
    /// Clear
    internal static let clear = Localized.tr("Localizable", "filter.clear", fallback: "Clear")
    /// Filters
    internal static let title = Localized.tr("Localizable", "filter.title", fallback: "Filters")
  }
  internal enum Library {
    /// Select from Photo Library
    internal static let selectFromPhotoLibrary = Localized.tr("Localizable", "library.select_from_photo_library", fallback: "Select from Photo Library")
  }
  internal enum Nodes {
    /// Gem Wallet Node
    internal static let gemWalletNode = Localized.tr("Localizable", "nodes.gem_wallet_node", fallback: "Gem Wallet Node")
    internal enum ImportNode {
      /// Chain ID
      internal static let chainId = Localized.tr("Localizable", "nodes.import_node.chain_id", fallback: "Chain ID")
      /// In Sync
      internal static let inSync = Localized.tr("Localizable", "nodes.import_node.in_sync", fallback: "In Sync")
      /// Latency
      internal static let latency = Localized.tr("Localizable", "nodes.import_node.latency", fallback: "Latency")
      /// Latest Block
      internal static let latestBlock = Localized.tr("Localizable", "nodes.import_node.latest_block", fallback: "Latest Block")
      /// Add node
      internal static let title = Localized.tr("Localizable", "nodes.import_node.title", fallback: "Add node")
    }
  }
  internal enum Receive {
    /// Receive %s
    internal static func title(_ p1: UnsafePointer<CChar>) -> String {
      return Localized.tr("Localizable", "receive.title", p1, fallback: "Receive %s")
    }
  }
  internal enum SecretPhrase {
    /// Save your Secret Phrase in a secure place 
    /// that only you control.
    internal static let savePhraseSafely = Localized.tr("Localizable", "secret_phrase.save_phrase_safely", fallback: "Save your Secret Phrase in a secure place \nthat only you control.")
    internal enum Confirm {
      internal enum QuickTest {
        /// Complete this quick test to confirm you've saved everything correctly.
        internal static let title = Localized.tr("Localizable", "secret_phrase.confirm.quick_test.title", fallback: "Complete this quick test to confirm you've saved everything correctly.")
      }
    }
    internal enum DoNotShare {
      /// If someone has your secret phrase they will have full control of your wallet!
      internal static let description = Localized.tr("Localizable", "secret_phrase.do_not_share.description", fallback: "If someone has your secret phrase they will have full control of your wallet!")
      /// Do not share your Secret Phrase!
      internal static let title = Localized.tr("Localizable", "secret_phrase.do_not_share.title", fallback: "Do not share your Secret Phrase!")
    }
  }
  internal enum Settings {
    /// About Us
    internal static let aboutus = Localized.tr("Localizable", "settings.aboutus", fallback: "About Us")
    /// Community
    internal static let community = Localized.tr("Localizable", "settings.community", fallback: "Community")
    /// Currency
    internal static let currency = Localized.tr("Localizable", "settings.currency", fallback: "Currency")
    /// Developer
    internal static let developer = Localized.tr("Localizable", "settings.developer", fallback: "Developer")
    /// Enable Passcode
    internal static let enablePasscode = Localized.tr("Localizable", "settings.enable_passcode", fallback: "Enable Passcode")
    /// Enable %@
    internal static func enableValue(_ p1: Any) -> String {
      return Localized.tr("Localizable", "settings.enable_value", String(describing: p1), fallback: "Enable %@")
    }
    /// Language
    internal static let language = Localized.tr("Localizable", "settings.language", fallback: "Language")
    /// Privacy Policy
    internal static let privacyPolicy = Localized.tr("Localizable", "settings.privacy_policy", fallback: "Privacy Policy")
    /// Rate App
    internal static let rateApp = Localized.tr("Localizable", "settings.rate_app", fallback: "Rate App")
    /// Security
    internal static let security = Localized.tr("Localizable", "settings.security", fallback: "Security")
    /// Terms of Services
    internal static let termsOfServices = Localized.tr("Localizable", "settings.terms_of_services", fallback: "Terms of Services")
    /// Settings
    internal static let title = Localized.tr("Localizable", "settings.title", fallback: "Settings")
    /// Version
    internal static let version = Localized.tr("Localizable", "settings.version", fallback: "Version")
    /// Visit Website
    internal static let website = Localized.tr("Localizable", "settings.website", fallback: "Visit Website")
    internal enum Networks {
      /// Explorer
      internal static let explorer = Localized.tr("Localizable", "settings.networks.explorer", fallback: "Explorer")
      /// Source
      internal static let source = Localized.tr("Localizable", "settings.networks.source", fallback: "Source")
      /// Networks
      internal static let title = Localized.tr("Localizable", "settings.networks.title", fallback: "Networks")
    }
    internal enum Notifications {
      /// Notifications
      internal static let title = Localized.tr("Localizable", "settings.notifications.title", fallback: "Notifications")
    }
    internal enum Security {
      /// Authentication
      internal static let authentication = Localized.tr("Localizable", "settings.security.authentication", fallback: "Authentication")
    }
  }
  internal enum SignMessage {
    /// Message
    internal static let message = Localized.tr("Localizable", "sign_message.message", fallback: "Message")
    /// Sign Message
    internal static let title = Localized.tr("Localizable", "sign_message.title", fallback: "Sign Message")
  }
  internal enum Social {
    /// CoinGecko
    internal static let coingecko = Localized.tr("Localizable", "social.coingecko", fallback: "CoinGecko")
    /// Discord
    internal static let discord = Localized.tr("Localizable", "social.discord", fallback: "Discord")
    /// Facebook
    internal static let facebook = Localized.tr("Localizable", "social.facebook", fallback: "Facebook")
    /// GitHub
    internal static let github = Localized.tr("Localizable", "social.github", fallback: "GitHub")
    /// Homepage
    internal static let homepage = Localized.tr("Localizable", "social.homepage", fallback: "Homepage")
    /// Links
    internal static let links = Localized.tr("Localizable", "social.links", fallback: "Links")
    /// Reddit
    internal static let reddit = Localized.tr("Localizable", "social.reddit", fallback: "Reddit")
    /// Telegram
    internal static let telegram = Localized.tr("Localizable", "social.telegram", fallback: "Telegram")
    /// X (formerly Twitter)
    internal static let x = Localized.tr("Localizable", "social.x", fallback: "X (formerly Twitter)")
    /// YouTube
    internal static let youtube = Localized.tr("Localizable", "social.youtube", fallback: "YouTube")
  }
  internal enum Stake {
    /// Activating
    internal static let activating = Localized.tr("Localizable", "stake.activating", fallback: "Activating")
    /// Active
    internal static let active = Localized.tr("Localizable", "stake.active", fallback: "Active")
    /// Active In
    internal static let activeIn = Localized.tr("Localizable", "stake.active_in", fallback: "Active In")
    /// APR %@
    internal static func apr(_ p1: Any) -> String {
      return Localized.tr("Localizable", "stake.apr", String(describing: p1), fallback: "APR %@")
    }
    /// Available In
    internal static let availableIn = Localized.tr("Localizable", "stake.available_in", fallback: "Available In")
    /// Awaiting Withdrawal
    internal static let awaitingWithdrawal = Localized.tr("Localizable", "stake.awaiting_withdrawal", fallback: "Awaiting Withdrawal")
    /// Deactivating
    internal static let deactivating = Localized.tr("Localizable", "stake.deactivating", fallback: "Deactivating")
    /// Inactive
    internal static let inactive = Localized.tr("Localizable", "stake.inactive", fallback: "Inactive")
    /// Lock Time
    internal static let lockTime = Localized.tr("Localizable", "stake.lock_time", fallback: "Lock Time")
    /// Minimum amount
    internal static let minimumAmount = Localized.tr("Localizable", "stake.minimum_amount", fallback: "Minimum amount")
    /// No active staking yet.
    internal static let noActiveStaking = Localized.tr("Localizable", "stake.no_active_staking", fallback: "No active staking yet.")
    /// Pending
    internal static let pending = Localized.tr("Localizable", "stake.pending", fallback: "Pending")
    /// Rewards
    internal static let rewards = Localized.tr("Localizable", "stake.rewards", fallback: "Rewards")
    /// Stake
    internal static let stake = Localized.tr("Localizable", "stake.stake", fallback: "Stake")
    /// Validator
    internal static let validator = Localized.tr("Localizable", "stake.validator", fallback: "Validator")
    /// Validators
    internal static let validators = Localized.tr("Localizable", "stake.validators", fallback: "Validators")
    /// Stake via Gem Wallet
    internal static let viagem = Localized.tr("Localizable", "stake.viagem", fallback: "Stake via Gem Wallet")
  }
  internal enum Swap {
    /// Approve %@ to Swap
    internal static func approveToken(_ p1: Any) -> String {
      return Localized.tr("Localizable", "swap.approve_token", String(describing: p1), fallback: "Approve %@ to Swap")
    }
    /// Approve %@ token for swap access.
    internal static func approveTokenPermission(_ p1: Any) -> String {
      return Localized.tr("Localizable", "swap.approve_token_permission", String(describing: p1), fallback: "Approve %@ token for swap access.")
    }
    /// Provider
    internal static let provider = Localized.tr("Localizable", "swap.provider", fallback: "Provider")
    /// You Pay
    internal static let youPay = Localized.tr("Localizable", "swap.you_pay", fallback: "You Pay")
    /// You Receive
    internal static let youReceive = Localized.tr("Localizable", "swap.you_receive", fallback: "You Receive")
  }
  internal enum Transaction {
    /// Date
    internal static let date = Localized.tr("Localizable", "transaction.date", fallback: "Date")
    /// Recipient
    internal static let recipient = Localized.tr("Localizable", "transaction.recipient", fallback: "Recipient")
    /// Sender
    internal static let sender = Localized.tr("Localizable", "transaction.sender", fallback: "Sender")
    /// Status
    internal static let status = Localized.tr("Localizable", "transaction.status", fallback: "Status")
    /// View on %@
    internal static func viewOn(_ p1: Any) -> String {
      return Localized.tr("Localizable", "transaction.view_on", String(describing: p1), fallback: "View on %@")
    }
    internal enum Status {
      /// Successful
      internal static let confirmed = Localized.tr("Localizable", "transaction.status.confirmed", fallback: "Successful")
      /// Failed
      internal static let failed = Localized.tr("Localizable", "transaction.status.failed", fallback: "Failed")
      /// Pending
      internal static let pending = Localized.tr("Localizable", "transaction.status.pending", fallback: "Pending")
      /// Reverted
      internal static let reverted = Localized.tr("Localizable", "transaction.status.reverted", fallback: "Reverted")
    }
    internal enum Title {
      /// Received
      internal static let received = Localized.tr("Localizable", "transaction.title.received", fallback: "Received")
      /// Sent
      internal static let sent = Localized.tr("Localizable", "transaction.title.sent", fallback: "Sent")
    }
  }
  internal enum Transfer {
    /// Address
    internal static let address = Localized.tr("Localizable", "transfer.address", fallback: "Address")
    /// Amount
    internal static let amount = Localized.tr("Localizable", "transfer.amount", fallback: "Amount")
    /// Balance: %@
    internal static func balance(_ p1: Any) -> String {
      return Localized.tr("Localizable", "transfer.balance", String(describing: p1), fallback: "Balance: %@")
    }
    /// Confirm
    internal static let confirm = Localized.tr("Localizable", "transfer.confirm", fallback: "Confirm")
    /// From
    internal static let from = Localized.tr("Localizable", "transfer.from", fallback: "From")
    /// Insufficient %@ balance.
    internal static func insufficientBalance(_ p1: Any) -> String {
      return Localized.tr("Localizable", "transfer.insufficient_balance", String(describing: p1), fallback: "Insufficient %@ balance.")
    }
    /// Insufficient %@ balance to cover network fees.
    internal static func insufficientNetworkFeeBalance(_ p1: Any) -> String {
      return Localized.tr("Localizable", "transfer.insufficient_network_fee_balance", String(describing: p1), fallback: "Insufficient %@ balance to cover network fees.")
    }
    /// Max
    internal static let max = Localized.tr("Localizable", "transfer.max", fallback: "Max")
    /// Memo
    internal static let memo = Localized.tr("Localizable", "transfer.memo", fallback: "Memo")
    /// Minimum Amount is %@
    internal static func minimumAmount(_ p1: Any) -> String {
      return Localized.tr("Localizable", "transfer.minimum_amount", String(describing: p1), fallback: "Minimum Amount is %@")
    }
    /// Network
    internal static let network = Localized.tr("Localizable", "transfer.network", fallback: "Network")
    /// Network Fee
    internal static let networkFee = Localized.tr("Localizable", "transfer.network_fee", fallback: "Network Fee")
    /// Step %d
    internal static func step(_ p1: Int) -> String {
      return Localized.tr("Localizable", "transfer.step", p1, fallback: "Step %d")
    }
    /// Transfer
    internal static let title = Localized.tr("Localizable", "transfer.title", fallback: "Transfer")
    /// To
    internal static let to = Localized.tr("Localizable", "transfer.to", fallback: "To")
    internal enum Amount {
      /// Amount
      internal static let title = Localized.tr("Localizable", "transfer.amount.title", fallback: "Amount")
    }
    internal enum Approve {
      /// Approve
      internal static let title = Localized.tr("Localizable", "transfer.approve.title", fallback: "Approve")
    }
    internal enum ClaimRewards {
      /// Claim Rewards
      internal static let title = Localized.tr("Localizable", "transfer.claim_rewards.title", fallback: "Claim Rewards")
    }
    internal enum Confirm {
      /// Max total
      internal static let maxtotal = Localized.tr("Localizable", "transfer.confirm.maxtotal", fallback: "Max total")
    }
    internal enum Recipient {
      /// Address or Name
      internal static let addressField = Localized.tr("Localizable", "transfer.recipient.address_field", fallback: "Address or Name")
      /// Recipient
      internal static let title = Localized.tr("Localizable", "transfer.recipient.title", fallback: "Recipient")
    }
    internal enum Redelegate {
      /// Redelegate
      internal static let title = Localized.tr("Localizable", "transfer.redelegate.title", fallback: "Redelegate")
    }
    internal enum Rewards {
      /// Rewards
      internal static let title = Localized.tr("Localizable", "transfer.rewards.title", fallback: "Rewards")
    }
    internal enum Send {
      /// Send
      internal static let title = Localized.tr("Localizable", "transfer.send.title", fallback: "Send")
    }
    internal enum Stake {
      /// Stake
      internal static let title = Localized.tr("Localizable", "transfer.stake.title", fallback: "Stake")
    }
    internal enum Unstake {
      /// Unstake
      internal static let title = Localized.tr("Localizable", "transfer.unstake.title", fallback: "Unstake")
    }
    internal enum Withdraw {
      /// Withdraw
      internal static let title = Localized.tr("Localizable", "transfer.withdraw.title", fallback: "Withdraw")
    }
  }
  internal enum UpdateApp {
    /// Update
    internal static let action = Localized.tr("Localizable", "update_app.action", fallback: "Update")
    /// Version %@ of the app is now available. Update and enjoy the latest features and improvements.
    internal static func description(_ p1: Any) -> String {
      return Localized.tr("Localizable", "update_app.description", String(describing: p1), fallback: "Version %@ of the app is now available. Update and enjoy the latest features and improvements.")
    }
    /// New update available!
    internal static let title = Localized.tr("Localizable", "update_app.title", fallback: "New update available!")
  }
  internal enum Wallet {
    /// Buy
    internal static let buy = Localized.tr("Localizable", "wallet.buy", fallback: "Buy")
    /// Copy Address
    internal static let copyAddress = Localized.tr("Localizable", "wallet.copy_address", fallback: "Copy Address")
    /// Create a New Wallet
    internal static let createNewWallet = Localized.tr("Localizable", "wallet.create_new_wallet", fallback: "Create a New Wallet")
    /// Wallet #%d
    internal static func defaultName(_ p1: Int) -> String {
      return Localized.tr("Localizable", "wallet.default_name", p1, fallback: "Wallet #%d")
    }
    /// %@ Wallet #%d
    internal static func defaultNameChain(_ p1: Any, _ p2: Int) -> String {
      return Localized.tr("Localizable", "wallet.default_name_chain", String(describing: p1), p2, fallback: "%@ Wallet #%d")
    }
    /// Import an Existing Wallet
    internal static let importExistingWallet = Localized.tr("Localizable", "wallet.import_existing_wallet", fallback: "Import an Existing Wallet")
    /// Manage Token List
    internal static let manageTokenList = Localized.tr("Localizable", "wallet.manage_token_list", fallback: "Manage Token List")
    /// Multi-Coin
    internal static let multicoin = Localized.tr("Localizable", "wallet.multicoin", fallback: "Multi-Coin")
    /// Name
    internal static let name = Localized.tr("Localizable", "wallet.name", fallback: "Name")
    /// Receive
    internal static let receive = Localized.tr("Localizable", "wallet.receive", fallback: "Receive")
    /// Scan
    internal static let scan = Localized.tr("Localizable", "wallet.scan", fallback: "Scan")
    /// Scan QR Code
    internal static let scanQrCode = Localized.tr("Localizable", "wallet.scan_qr_code", fallback: "Scan QR Code")
    /// Send
    internal static let send = Localized.tr("Localizable", "wallet.send", fallback: "Send")
    /// Stake
    internal static let stake = Localized.tr("Localizable", "wallet.stake", fallback: "Stake")
    /// Swap
    internal static let swap = Localized.tr("Localizable", "wallet.swap", fallback: "Swap")
    /// Wallet
    internal static let title = Localized.tr("Localizable", "wallet.title", fallback: "Wallet")
    internal enum AddToken {
      /// Add Token
      internal static let title = Localized.tr("Localizable", "wallet.add_token.title", fallback: "Add Token")
    }
    internal enum Import {
      /// Import
      internal static let action = Localized.tr("Localizable", "wallet.import.action", fallback: "Import")
      /// Address or Name
      internal static let addressField = Localized.tr("Localizable", "wallet.import.address_field", fallback: "Address or Name")
      /// Contract Address or Token ID
      internal static let contractAddressField = Localized.tr("Localizable", "wallet.import.contract_address_field", fallback: "Contract Address or Token ID")
      /// %s encoded private key
      internal static func privateKey(_ p1: UnsafePointer<CChar>) -> String {
        return Localized.tr("Localizable", "wallet.import.private_key", p1, fallback: "%s encoded private key")
      }
      /// Secret Recovery Phrase
      internal static let secretPhrase = Localized.tr("Localizable", "wallet.import.secret_phrase", fallback: "Secret Recovery Phrase")
      /// Import Wallet
      internal static let title = Localized.tr("Localizable", "wallet.import.title", fallback: "Import Wallet")
    }
    internal enum New {
      /// Confirm that you've written down and stored your Secret Recovery Phrase securely before proceeding, as it is crucial for future wallet access and recovery.
      internal static let backupConfirmWarning = Localized.tr("Localizable", "wallet.new.backup_confirm_warning", fallback: "Confirm that you've written down and stored your Secret Recovery Phrase securely before proceeding, as it is crucial for future wallet access and recovery.")
      /// Write down your unique Secret Recovery Phrase and store it securely; it's essential for wallet access and recovery.
      internal static let backupWarning = Localized.tr("Localizable", "wallet.new.backup_warning", fallback: "Write down your unique Secret Recovery Phrase and store it securely; it's essential for wallet access and recovery.")
      /// New Wallet
      internal static let title = Localized.tr("Localizable", "wallet.new.title", fallback: "New Wallet")
    }
    internal enum Receive {
      /// No destination tag required
      internal static let noDestinationTagRequired = Localized.tr("Localizable", "wallet.receive.no_destination_tag_required", fallback: "No destination tag required")
      /// No memo required
      internal static let noMemoRequired = Localized.tr("Localizable", "wallet.receive.no_memo_required", fallback: "No memo required")
    }
    internal enum Watch {
      internal enum Tooltip {
        /// You are watching this wallet.
        internal static let title = Localized.tr("Localizable", "wallet.watch.tooltip.title", fallback: "You are watching this wallet.")
      }
    }
  }
  internal enum WalletConnect {
    /// App
    internal static let app = Localized.tr("Localizable", "wallet_connect.app", fallback: "App")
    /// WalletConnect
    internal static let brandName = Localized.tr("Localizable", "wallet_connect.brand_name", fallback: "WalletConnect")
    /// Disconnect
    internal static let disconnect = Localized.tr("Localizable", "wallet_connect.disconnect", fallback: "Disconnect")
    /// No active connections
    internal static let noActiveConnections = Localized.tr("Localizable", "wallet_connect.no_active_connections", fallback: "No active connections")
    /// WalletConnect
    internal static let title = Localized.tr("Localizable", "wallet_connect.title", fallback: "WalletConnect")
    /// Website
    internal static let website = Localized.tr("Localizable", "wallet_connect.website", fallback: "Website")
    internal enum Connect {
      /// Connect
      internal static let title = Localized.tr("Localizable", "wallet_connect.connect.title", fallback: "Connect")
    }
    internal enum Connection {
      /// Connection
      internal static let title = Localized.tr("Localizable", "wallet_connect.connection.title", fallback: "Connection")
    }
  }
  internal enum Wallets {
    /// Wallets
    internal static let title = Localized.tr("Localizable", "wallets.title", fallback: "Wallets")
    /// Watch
    internal static let watch = Localized.tr("Localizable", "wallets.watch", fallback: "Watch")
  }
  internal enum Welcome {
    /// Welcome to Gem Family
    internal static let title = Localized.tr("Localizable", "welcome.title", fallback: "Welcome to Gem Family")
    internal enum Legal {
      /// By using Gem, you agree to accept our
      ///  [Terms of Use](%s) and [Privacy Policy](%s)
      internal static func concent(_ p1: UnsafePointer<CChar>, _ p2: UnsafePointer<CChar>) -> String {
        return Localized.tr("Localizable", "welcome.legal.concent", p1, p2, fallback: "By using Gem, you agree to accept our\n [Terms of Use](%s) and [Privacy Policy](%s)")
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension Localized {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
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
