import Foundation
import SwiftUI

public typealias Spacing = CGFloat
public typealias Sizing = CGFloat

public extension Spacing {
    /// 2
    static let space2: Spacing = 2
    /// 4
    static let space4: Spacing = 4
    /// 8
    static let space8: Spacing = 8
    /// 16
    static let space16: Spacing = 16
    /// 24
    static let space24: Spacing = 24
    /// 32
    static let space32: Spacing = 32

    // semantic aliases

    /// 2
    static let extraSmall: CGFloat = space2
    /// 4
    static let tiny: CGFloat = space4
    /// 8
    static let small: CGFloat = space8
    /// 16
    static let medium: CGFloat = space16
    /// 24
    static let large: CGFloat = space24
    /// 32
    static let extraLarge: CGFloat = space32

    static func spacingOr(condition: Bool, value: Spacing, opposite: Spacing = .zero) -> Spacing {
        return condition ? value : opposite
    }

    var edgeInsets: EdgeInsets {
        EdgeInsets(top: self, leading: self, bottom: self, trailing: self)
    }

    struct scene {
        /// 16
        public static let top: CGFloat = space16
        /// 8
        public static let bottom: CGFloat = space8

        public struct button {
            /// 340
            public static let maxWidth: CGFloat = 340
            /// 44
            public static let accessoryHeight: CGFloat = 44
            /// 50
            public static let height: CGFloat = 50
        }

        public struct content {
            /// 360
            public static let maxWidth: CGFloat = 360
        }
    }
}

public extension Sizing {
    struct image {
        /// 4
        public static let tiny: CGFloat = 10
        /// 22
        public static let small: CGFloat = 22
        /// 34
        public static let semiMedium: CGFloat = 34
        /// 44
        public static let medium: CGFloat = 44
        /// 88
        public static let large: CGFloat = 88
        /// 112
        public static let semiExtraLarge: CGFloat = 112
        /// 120
        public static let extraLarge: CGFloat = 120
        
        /// 44
        public static let asset: CGFloat = 44
    }

    struct list {
        /// 22
        public static let image: CGFloat = 22
        
        public struct selected {
            /// 20
            public static let image: CGFloat = 20
        }
        
        public struct assets {
            public static let height: CGFloat = Sizing.image.asset
        }
    
        public struct transactions {
            public static let height: CGFloat = Sizing.image.asset
        }
    }
    
    struct presentation {
        /// 24
        public static let cornerRadius: CGFloat = 24
    }
}
