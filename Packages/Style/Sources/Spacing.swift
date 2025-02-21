import Foundation

public struct Spacing {
    /// 2
    public static let extraSmall: CGFloat = 2
    /// 4
    public static let tiny: CGFloat = 4
    /// 8
    public static let small: CGFloat = 8
    /// 16
    public static let medium: CGFloat = 16
    /// 24
    public static let large: CGFloat = 24
    /// 32
    public static let extraLarge: CGFloat = 32

    public struct scene {
        /// 16
        public static let top: CGFloat = 16
        /// 8
        public static let bottom: CGFloat = 8

        public struct button {
            /// 340
            public static let maxWidth: CGFloat = 340
        }

        public struct content {
            /// 360
            public static let maxWidth: CGFloat = 360
        }
    }
}

public struct Sizing {
    public struct image {
        /// 4
        public static let tiny: CGFloat = 10
        /// 22
        public static let small: CGFloat = 22
        /// 44
        public static let medium: CGFloat = 44
        /// 88
        public static let large: CGFloat = 88
        /// 112
        public static let semiLarge: CGFloat = 112
        /// 120
        public static let extraLarge: CGFloat = 120
    }

    public struct list {
        /// 22
        public static let image: CGFloat = 22

        public struct selected {
            /// 20
            public static let image: CGFloat = 20
        }
    }
    
    public struct Presentation {
        /// 24
        public static let cornerRadius: CGFloat = 24
    }
}
