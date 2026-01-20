# 💎 Gem Wallet - iOS

[![Unit Tests](https://github.com/gemwalletcom/gem-ios/actions/workflows/ci.yml/badge.svg)](https://github.com/gemwalletcom/gem-ios/actions/workflows/ci.yml)
[![License](https://badgen.net/github/license/gemwalletcom/gem-android)](https://github.com/gemwalletcom/gem-android/blob/main/LICENSE)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/gemwalletcom/gem-ios)
[![Gem Wallet Discord](https://img.shields.io/discord/974531300394434630?style=plastic)](https://discord.gg/aWkq5sj7SY)
[![X (formerly Twitter) Follow](https://img.shields.io/twitter/follow/GemWalletApp)](https://x.com/GemWalletApp)
[![Telegram](https://img.shields.io/badge/Telegram-2CA5E0?style=flat&logo=telegram&logoColor=white)](https://t.me/gemwallet_developers)

<b>Gem Wallet</b> is a powerful and secure mobile application designed for iOS and [Android](https://github.com/gemwalletcom/gem-android). It provides users with a seamless and intuitive experience to manage their digital assets and cryptocurrencies.

The app is developed using SwiftUI. The codebase also includes a [Core](https://github.com/gemwalletcom/core) library implemented in Rust, providing efficient and secure cryptographic operations for enhanced data protection.

📲️ [iOS available on the App Store.](https://apps.apple.com/app/apple-store/id6448712670?ct=github&mt=8)

🤖 [Android available on the Google Play Store.](https://play.google.com/store/apps/details?id=com.gemwallet.android&utm_campaign=github&utm_source=referral&utm_medium=github)

## ✨ Features

- 👨‍👩‍👧‍👦 **Open Source & Community Owned** with web3 ethos.
- 🗝️ **Self-Custody** Exclusive ownership and access to funds.
- 🔑 **Secure** and **Privacy** preserving wallet.
- 🔗 **Multi-Chain Support:** Supports Ethereum, Binance Smart Chain, Polygon, Avalanche, Solana, and more.
- 🔄 **Swaps:** Exchange cryptocurrencies quickly and easily.
- 📈 **Staking:** Earn rewards by staking assets.
- 🌐 **WalletConnect:** Secure communication with decentralized applications (dApps).
- 🌍 **Fiat On/Off Ramp:** Easily convert between cryptocurrencies and traditional currencies.
- 🗃️ **Backup and Recovery:** Simple backup and recovery options.
- 📈 **Real-Time Market Data:** Integrated with real-time price tracking and market data.
- 🔄 **Instant Transactions:** Fast and efficient transactions with low fees.
- 🔔 **Customizable Notifications:** Set alerts for transactions, price changes, and important events.
- 🛡️ **Advanced Security:** Encryption and secure key management.

<img src="https://assets.gemwallet.com/screenshots/github_preview.png" />

## 🏄‍♂️ Contributing

- Look in to our [Github Issues](https://github.com/gemwalletcom/gem-ios/issues)
- See progress on our [Github Project Board](https://github.com/orgs/gemwalletcom/projects/2)
- Public [Roadmap](https://github.com/orgs/gemwalletcom/projects/4)

See our [Contributing Guidelines](./CONTRIBUTING.md).

## 🥰 Community

- Install the app [Gem Wallet](https://gemwallet.com)
- Join our [Discord](https://discord.gg/aWkq5sj7SY)
- Follow on [Twitter](https://twitter.com/GemWalletApp) or join [Telegram](https://t.me/GemWallet)

## 🙋 Getting Help

- Join the [Telegram](https://t.me/gemwallet_developers) to get help, or
- Open a [discussion](https://github.com/gemwalletcom/gem-ios/discussions/new) with your question, or
- Open an issue with [the bug](https://github.com/gemwalletcom/gem-ios/issues/new)

If you want to contribute, you can use our [developers telegram](https://t.me/gemwallet_developers) to chat with us about further development!

## 🚀 Getting Started

### iOS Development

> [!NOTE]
> Gem iOS needs [Apple silicon Mac](https://support.apple.com/en-us/116943) to build by default.

1. Setup [Xcode](https://developer.apple.com/xcode)
2. Clone the repo `git clone https://github.com/gemwalletcom/gem-ios.git --recursive`
3. Run `just bootstrap` to install all necessary tools. Make sure you have `just` installed `brew install just`. 

If you're using a legacy Intel Mac, you need to pull latest `core` submodule and run `just generate-stone` to build `x86_64` arch Gemstone, the core library used by Gem iOS.


## 👨‍👧‍👦 Contributors

We love contributors! Feel free to contribute to this project but please read the [Contributing Guidelines](CONTRIBUTING.md) first!

## 🌍 Localization

Join us in making our app accessible worldwide! Contribute to localization efforts by visiting our [Lokalise project](https://app.lokalise.com/public/94865410644ee707546334.60736699/)

## ⚖️ License

Gem Wallet is open-sourced software licensed under the © [GPL-3.0](LICENSE).
