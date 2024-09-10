import Foundation

public struct Spacing {
    public static let extraSmall: CGFloat = 2
    public static let tiny: CGFloat = 4
    public static let small: CGFloat = 8
    public static let medium: CGFloat = 16
    public static let large: CGFloat = 24
    public static let extraLarge: CGFloat = 32
    
    public struct scene {
        public static let top: CGFloat = 16
        public static let bottom: CGFloat = 8
        public struct button {
            public static let maxWidth: CGFloat = 340
        }
        public struct content {
            public static let maxWidth: CGFloat = 360
        }
    }
}

public struct Sizing {
    public struct image {
        public static let chain: CGFloat = 44
    }
    
    public struct list {
        public static let image: CGFloat = 22
    }
}
