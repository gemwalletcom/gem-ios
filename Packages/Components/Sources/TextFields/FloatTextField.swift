// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct FloatFieldStyle {
    public let placeholderScale: CGFloat
    public let activePlaceholderColor: Color
    public let placeholderColor: Color

    public init(
        placeholderScale: CGFloat,
        placeholderColor: Color,
        activePlaceholderColor: Color
    ) {
        self.placeholderScale = placeholderScale
        self.activePlaceholderColor = activePlaceholderColor
        self.placeholderColor = placeholderColor
    }

    public static var standard: FloatFieldStyle {
        FloatFieldStyle(
            placeholderScale: 0.8,
            placeholderColor: Colors.gray,
            activePlaceholderColor: Colors.grayLight
        )
    }
}

public struct FloatTextField<TrailingView: View>: View {
    @Binding private var text: String

    private let placeholder: String
    private let style: FloatFieldStyle

    private var allowClean: Bool
    private var trailingView: TrailingView

    public init(
        _ placeholder: String,
        text: Binding<String>,
        style: FloatFieldStyle = .standard,
        allowClean: Bool = true,
        @ViewBuilder trailingView: () -> TrailingView = { EmptyView() }
    ) {
        _text = text
        self.placeholder = placeholder
        self.style = style
        self.allowClean = allowClean
        self.trailingView = trailingView()
    }

    public var body: some View {
        ZStack(alignment: .leading) {
            placeholderView
            HStack {
                textField
                if shouldShowSpacer {
                    Spacer(minLength: Spacing.small)
                }
                trailingContent
            }
        }
        .padding(.vertical, Spacing.small)
        .onAppear {
            UITextField.appearance().clearButtonMode = .never
        }
    }

    private var shouldShowSpacer: Bool {
        shouldShowClean || !(trailingView is EmptyView)
    }

    private var shouldShowClean: Bool {
        allowClean && !text.isEmpty
    }

    private func onSelectClean() {
        text = ""
    }
}

// MARK: - UI Components

extension FloatTextField {
    private var placeholderView: some View {
        Text(placeholder)
            .textStyle(
                TextStyle(
                    font: text.isEmpty ? .body : .body.weight(.semibold),
                    color: text.isEmpty ? style.placeholderColor : style.activePlaceholderColor
                )
            )
            .scaleEffect(text.isEmpty ? 1 : style.placeholderScale, anchor: .leading)
            .offset(y: text.isEmpty ? .zero : -Spacing.small - Spacing.extraSmall)
            .animation(.smooth(duration: 0.15), value: text.isEmpty)
    }

    private var textField: some View {
        TextField("", text: $text)
            .offset(y: text.isEmpty ? .zero : Spacing.small + Spacing.extraSmall)
            .animation(.smooth(duration: 0.15), value: text.isEmpty)
    }

    private var trailingContent: some View {
        Group {
            if shouldShowClean {
                Button(action: onSelectClean) {
                    Images.System.clear
                        .foregroundStyle(Colors.gray)
                }
                .buttonStyle(.plain)
            } else {
                trailingView
            }
        }
    }
}

// MARK: - Previews

#Preview {
    ScrollView {
        VStack(spacing: Spacing.medium) {
            FloatTextField(
                "Enter your text",
                text: .constant("")
            ) {}

            FloatTextField(
                "Enter your text",
                text: .constant("Some text")
            ) {}

            FloatTextField(
                "Enter your email",
                text: .constant(""),
                style: FloatFieldStyle(
                    placeholderScale: 0.9,
                    placeholderColor: .orange,
                    activePlaceholderColor: .red
                )
            ) {}

            FloatTextField(
                "Enter your password",
                text: .constant("password123"),
                style: FloatFieldStyle(
                    placeholderScale: 0.75,
                    placeholderColor: .blue,
                    activePlaceholderColor: .green
                )
            ) {
                Button(action: { print("Show Password") }) {
                    Image(systemName: "eye.slash")
                        .foregroundColor(.blue)
                }
            }

            FloatTextField(
                "Enter your username",
                text: .constant("JohnDoe")
            ) {
                HStack {
                    Button(action: { print("Clear") }) {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.red)
                    }
                    Button(action: { print("Edit") }) {
                        Image(systemName: "pencil")
                            .foregroundColor(.green)
                    }
                }
            }

            FloatTextField(
                "Enter your phone number",
                text: .constant("")
            ) {
                Button(action: { print("Select Country Code") }) {
                    Image(systemName: "flag.fill")
                        .foregroundColor(.purple)
                }
            }
        }
        .padding()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.black.opacity(0.1))
}
