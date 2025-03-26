import SwiftUI

public struct Colors {
    public static let white = Color.dynamicColor("#FFFFFF", dark: "#222222")
    public static let whiteSolid = Color.dynamicColor("FFFFFF")
    public static let black = Color.dynamicColor("#222222", dark: "FFFFFF")
    public static let blue = Color.dynamicColor("#2D5BE6")
    public static let blueDark = Color.dynamicColor("#1742C5")
    public static let red = Color.dynamicColor("#F84E4E")
    public static let redLight = Color.dynamicColor("#FFF1F1", dark: "#462D30")
    public static let green = Color.dynamicColor("#1B9A6C")
    public static let greenLight = Color.dynamicColor("EAFAF5", dark: "27423C")
    public static let orange = Color.dynamicColor("#FF9314")
    public static let gray = Color.dynamicColor("#818181")
    public static let grayLight = Color.dynamicColor("#969996")
    public static let grayVeryLight = Color.dynamicColor("#F4F4F4", dark: "#333333")
    public static let grayBackground = Color.dynamicColor("#F2F2F7", dark: "#1C1C1E")
    public static let grayDarkBackground = Color.dynamicColor("#E6E6F0", dark: "#1C1C1E")
    public static let secondaryText = Color.dynamicColor("#818181")
    public static let listStyleColor = UIColor.dynamicColor(UIColor.systemBackground.color, dark: UIColor.secondarySystemBackground.color)
    public static let insetGroupedListStyle = UIColor.dynamicColor(UIColor.systemGroupedBackground.color, dark: UIColor.black.color
    )
    public static let emptyBackgroundText = Color.dynamicColor("#777A80")
    public static let emptyBackground = Color.dynamicColor("#CACACE", dark: "3D3D3D")
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
        ("List style color", Colors.listStyleColor),
        ("Inset Gropued List style color", Colors.insetGroupedListStyle),
    ]
    return List {
        ForEach(colors, id: \.name) { color in
            HStack {
                Text(color.name)
                    .multilineTextAlignment(.leading)
                    .frame(width: 174)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(color.color)
                    .padding(.extraSmall)
                    .colorScheme(.light)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(color.color)
                    .padding(.extraSmall)
                    .colorScheme(.dark)
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0))
        }
    }
    .listStyle(InsetGroupedListStyle())
}

