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
        ("Green Light", Colors.greenLight),
        ("Orange", Colors.orange),
        ("Gray", Colors.gray),
        ("Gray Light", Colors.grayLight),
        ("Gray Very Light", Colors.grayVeryLight),
        ("Gray Background", Colors.grayBackground),
        ("Gray Dark Background", Colors.grayDarkBackground),
        ("Secondary Text", Colors.secondaryText),
    ]
    return List {
        ForEach(colors, id: \.name) { color in
            HStack {
                Text(color.name)
                    .multilineTextAlignment(.leading)
                    .frame(width: 174)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(color.color)
                    .padding(Spacing.extraSmall)
                    .colorScheme(.light)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(color.color)
                    .padding(Spacing.extraSmall)
                    .colorScheme(.dark)
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0))
        }
    }
    .listStyle(InsetGroupedListStyle())
}

