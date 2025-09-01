// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum Localized {
  public enum Widget {
    public enum Medium {
      /// Track prices of top cryptocurrencies
      public static let description = Localized.tr("Localizable", "widget.medium.description", fallback: "Track prices of top cryptocurrencies")
      /// Top Crypto Price
      public static let name = Localized.tr("Localizable", "widget.medium.name", fallback: "Top Crypto Price")
    }
    public enum Small {
      /// Track Bitcoin price
      public static let description = Localized.tr("Localizable", "widget.small.description", fallback: "Track Bitcoin price")
      /// Bitcoin Price
      public static let name = Localized.tr("Localizable", "widget.small.name", fallback: "Bitcoin Price")
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
