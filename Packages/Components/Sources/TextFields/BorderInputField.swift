import SwiftUI
import Style

public struct InputFieldStyle {
    public let cornerRadius: CGFloat
    public let placeholderScale: CGFloat
    public let borderColor: Color
    public let activePlaceholderColor: Color
    public let placeholderColor: Color
    public let errorColor: Color
    public let focusedBorderColor: Color
    public let focusedBackgroundColor: Color
    public let unfocusedBackgroundColor: Color
    public let errorBackgroundColor: Color

    public init(
        cornerRadius: CGFloat,
        placeholderScale: CGFloat,
        borderColor: Color,
        focusedBorderColor: Color,
        placeholderColor: Color,
        activePlaceholderColor: Color,
        errorColor: Color,
        focusedBackgroundColor: Color,
        unfocusedBackgroundColor: Color,
        errorBackgroundColor: Color
    ) {
        self.cornerRadius = cornerRadius
        self.placeholderScale = placeholderScale
        self.borderColor = borderColor
        self.activePlaceholderColor = activePlaceholderColor
        self.placeholderColor = placeholderColor
        self.errorColor = errorColor
        self.focusedBorderColor = focusedBorderColor

        self.focusedBackgroundColor = focusedBackgroundColor
        self.unfocusedBackgroundColor = unfocusedBackgroundColor
        self.errorBackgroundColor = errorBackgroundColor
    }

    public static var standard: InputFieldStyle {
        InputFieldStyle(
            cornerRadius: 16,
            placeholderScale: 0.75,
            borderColor: Colors.gray,
            focusedBorderColor: Colors.blue,
            placeholderColor: Colors.grayLight,
            activePlaceholderColor: Colors.gray,
            errorColor: Colors.red,
            focusedBackgroundColor: Colors.white.opacity(0.9),
            unfocusedBackgroundColor: Colors.white,
            errorBackgroundColor: Colors.red.opacity(0.1)
        )
    }
}

// MARK: - BorderInputField

public enum BorderField: String, Hashable {
    case borderField
    public var id: String { rawValue }
}

public struct BorderInputField<TrailingButtons: View>: View {
    @Binding private var text: String

    private let placeholder: String
    private let isValid: Bool
    private let style: InputFieldStyle
    private let validationMessage: String?
    private let focusedFieldBinding: FocusState<BorderField?>.Binding
    private let allowClean: Bool
    private var trailingButtons: TrailingButtons

    private var isFocused: Bool {
        focusedFieldBinding.wrappedValue != nil
    }

    public init(
        _ placeholder: String,
        text: Binding<String>,
        focusedField: FocusState<BorderField?>.Binding,
        style: InputFieldStyle = .standard,
        isValid: Bool = true,
        validationMessage: String? = nil,
        allowClean: Bool = true,
        @ViewBuilder trailingButtons: () -> TrailingButtons
    ) {
        _text = text
        self.placeholder = placeholder
        self.focusedFieldBinding = focusedField
        self.style = style
        self.isValid = isValid
        self.validationMessage = validationMessage
        self.allowClean = allowClean
        self.trailingButtons = trailingButtons()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
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
            .padding(.vertical, Spacing.medium + Spacing.tiny)
            .padding(.horizontal, Spacing.large/2)
            .background(
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .fill(stateBackground)
                    .stroke(borderBackground, lineWidth: 2)
            )
            .animation(.smooth(duration: 0.1), value: focusedFieldBinding.wrappedValue)

            if let validationMessage = validationMessage, !isValid {
                Text(validationMessage)
                    .textStyle(
                        TextStyle(font: .caption, color: style.errorColor)
                    )
                    .font(.caption)
                    .padding(.top, Spacing.small)
            }
        }
        .tint(stateTint)
        .onAppear {
            UITextField.appearance().clearButtonMode = .never
        }
    }

    private var placeholderView: some View {
        Text(placeholder)
            .textStyle(
                TextStyle(font: .body, color: text.isEmpty ? style.placeholderColor : style.activePlaceholderColor)
            )
            .scaleEffect(text.isEmpty ? 1 : style.placeholderScale, anchor: .leading)
            .offset(y: text.isEmpty ? .zero : -Spacing.small - Spacing.extraSmall)
            .animation(.smooth(duration: 0.15), value: text.isEmpty)
    }

    private var textField: some View {
        TextField("", text: $text)
            .focused(focusedFieldBinding, equals: .borderField)
            .offset(y: text.isEmpty ? .zero : Spacing.small + Spacing.extraSmall)
            .autocorrectionDisabled()
            .animation(.smooth(duration: 0.15), value: text.isEmpty)
    }

    private var trailingContent: some View {
        Group {
            if shouldShowClean {
                Button(action: onSelectClean) {
                    Image(systemName: SystemImage.clear)
                        .foregroundStyle(Colors.gray)
                }
                .buttonStyle(.plain)
            } else {
                trailingButtons
            }
        }
    }

    private var stateTint: Color {
        isValid ? (isFocused ? style.focusedBorderColor : style.placeholderColor) : style.errorColor
    }

    private var stateBackground: Color {
        isValid ? (isFocused ? style.focusedBackgroundColor : style.unfocusedBackgroundColor) : style.errorBackgroundColor
    }

    private var borderBackground: Color {
        isValid ? (isFocused ? style.focusedBorderColor : style.borderColor) : style.errorColor
    }

    private var shouldShowSpacer: Bool {
        shouldShowClean || !(trailingButtons is EmptyView)
    }

    private var shouldShowClean: Bool {
        allowClean && !text.isEmpty
    }

    private func onSelectClean() {
        text = ""
    }
}

// MARK: - Preview

#Preview {
    @State var text = ""
    @FocusState var isFocused: BorderField?

    return ScrollView {
        VStack {
            BorderInputField(
                "Enter your text",
                text: $text,
                focusedField: $isFocused
            ){}
            BorderInputField(
                "Enter your text",
                text: .constant("Some text"),
                focusedField: $isFocused
            ){}
            BorderInputField(
                "Enter your email",
                text: .constant("Invalid email"),
                focusedField: $isFocused,
                isValid: false,
                validationMessage: "Invalid email format"
            ){}
            BorderInputField(
                "Enter your text",
                text: .constant(""),
                focusedField: $isFocused
            ){}

            BorderInputField(
                "Enter your text",
                text: $text,
                focusedField: $isFocused
            ) {
                HStack {
                    Button(action: { print("Action 1") }) {
                        Image(systemName: "doc.on.clipboard")
                            .foregroundColor(.blue)
                    }
                    Button(action: { print("Action 2") }) {
                        Image(systemName: "qrcode.viewfinder")
                            .foregroundColor(.blue)
                    }
                }
            }

            BorderInputField(
                "Enter your email",
                text: .constant("Invalid email"),
                focusedField: $isFocused,
                style: InputFieldStyle(
                    cornerRadius: 12,
                    placeholderScale: 0.75,
                    borderColor: .orange,
                    focusedBorderColor: .red,
                    placeholderColor: .orange.opacity(0.7),
                    activePlaceholderColor: .orange,
                    errorColor: .red,
                    focusedBackgroundColor: .yellow.opacity(0.2),
                    unfocusedBackgroundColor: .orange.opacity(0.1),
                    errorBackgroundColor: .red.opacity(0.1)
                ),
                isValid: false,
                validationMessage: "Invalid email format"
            ) {
                HStack {
                    Button(action: { print("Action 1") }) {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.red)
                    }
                }
            }

            BorderInputField(
                "Enter your password",
                text: .constant(""),
                focusedField: $isFocused,
                style: InputFieldStyle(
                    cornerRadius: 20,
                    placeholderScale: 0.7,
                    borderColor: .gray,
                    focusedBorderColor: .purple,
                    placeholderColor: .white.opacity(0.6),
                    activePlaceholderColor: .white,
                    errorColor: .red,
                    focusedBackgroundColor: .black.opacity(0.8),
                    unfocusedBackgroundColor: .black.opacity(0.7),
                    errorBackgroundColor: .red.opacity(0.3)
                )
            ) {
                HStack {
                    Button(action: { print("Show Password") }) {
                        Image(systemName: "eye.slash")
                            .foregroundColor(.white)
                    }
                }
            }

            BorderInputField(
                "Enter your username",
                text: .constant("JohnDoe"),
                focusedField: $isFocused,
                style: InputFieldStyle(
                    cornerRadius: 8,
                    placeholderScale: 0.8,
                    borderColor: .green,
                    focusedBorderColor: .cyan,
                    placeholderColor: .green.opacity(0.6),
                    activePlaceholderColor: .cyan,
                    errorColor: .red,
                    focusedBackgroundColor: .green.opacity(0.2),
                    unfocusedBackgroundColor: .green.opacity(0.1),
                    errorBackgroundColor: .red.opacity(0.1)
                )
            ) {
                HStack {
                    Button(action: { print("Search") }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.cyan)
                    }
                }
            }
        }
        .padding()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.black.opacity(0.1))
}
