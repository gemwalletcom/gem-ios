import Foundation

@resultBuilder
public struct ListItemBuilder<Item: ListItemRepresentable> {
    public static func buildBlock(_ components: Item...) -> [Item] {
        components
    }
    
    public static func buildBlock(_ components: [Item]...) -> [Item] {
        components.flatMap { $0 }
    }

    public static func buildOptional(_ component: [Item]?) -> [Item] {
        component ?? []
    }
    
    public static func buildEither(first component: [Item]) -> [Item] {
        component
    }
    
    public static func buildEither(second component: [Item]) -> [Item] {
        component
    }
    
    public static func buildArray(_ components: [[Item]]) -> [Item] {
        components.flatMap { $0 }
    }
    
    public static func buildExpression(_ expression: Item) -> [Item] {
        [expression]
    }
    
    public static func buildExpression(_ expression: [Item]) -> [Item] {
        expression
    }
    
    public static func buildLimitedAvailability(_ component: [Item]) -> [Item] {
        component
    }
    
    public static func buildFinalResult(_ component: [Item]) -> [Item] {
        component
    }
}

// MARK: - Result Builder for Sections

@resultBuilder
public struct SectionBuilder<Section: ListSectionRepresentable> {
    public static func buildBlock(_ components: Section...) -> [Section] {
        components
    }
    
    public static func buildBlock(_ components: [Section]...) -> [Section] {
        components.flatMap { $0 }
    }
    
    public static func buildOptional(_ component: [Section]?) -> [Section] {
        component ?? []
    }
    
    public static func buildEither(first component: [Section]) -> [Section] {
        component
    }
    
    public static func buildEither(second component: [Section]) -> [Section] {
        component
    }
    
    public static func buildArray(_ components: [[Section]]) -> [Section] {
        components.flatMap { $0 }
    }
    
    public static func buildExpression(_ expression: Section) -> [Section] {
        [expression]
    }
    
    public static func buildExpression(_ expression: [Section]) -> [Section] {
        expression
    }
    
    public static func buildLimitedAvailability(_ component: [Section]) -> [Section] {
        component
    }
}
