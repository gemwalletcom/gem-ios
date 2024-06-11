// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public struct Colors {
    public static let white = Color("white", bundle: .style)
    public static let whiteSolid = Color("whiteSolid", bundle: .style)
    public static let black = Color("black", bundle: .style)
    public static let blue = Color("blue", bundle: .style)
    public static let blueDark = Color("blueDark", bundle: .style)
    public static let red = Color("red", bundle: .style)
    public static let redLight = Color("redLight", bundle: .style)
    public static let green = Color("green", bundle: .style)
    public static let orange = Color("orange", bundle: .style)
    public static let orangeLight = Color("orangeLight", bundle: .style)
    public static let greenLight = Color("greenLight", bundle: .style)
    public static let gray = Color("gray", bundle: .style)
    public static let grayBackground = Color("grayBackground", bundle: .style)
    public static let grayDarkBackground = Color("grayDarkBackground", bundle: .style)
    public static let grayLight = Color("grayLight", bundle: .style)
    public static let grayVeryLight = Color("grayVeryLight", bundle: .style)
    public static let secondaryText = Color("secondaryText", bundle: .style)
}

// MARK: - Previews

#Preview {
    let colors: [(name: String, color: Color)] = [
        ("White", Colors.white),
        ("White Solid", Colors.whiteSolid),
        ("Black", Colors.black),
        ("Blue", Colors.blue),
        ("Blue Dark", Colors.blueDark),
        ("Red", Colors.red),
        ("Red Light", Colors.redLight),
        ("Green", Colors.green),
        ("Orange", Colors.orange),
        ("Orange Light", Colors.orangeLight),
        ("Green Light", Colors.greenLight),
        ("Gray", Colors.gray),
        ("Gray Background", Colors.grayBackground),
        ("Gray Dark Background", Colors.grayDarkBackground),
        ("Gray Light", Colors.grayLight),
        ("Gray Very Light", Colors.grayVeryLight),
        ("Secondary Text", Colors.secondaryText)
    ]

    return ScrollView {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 16) {
            ForEach(colors, id: \.name) { color in
                VStack {
                    Rectangle()
                        .fill(color.color)
                        .frame(height: 100)
                        .cornerRadius(8)
                    Text(color.name)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 4)
            }
        }
        .padding()
    }
}
