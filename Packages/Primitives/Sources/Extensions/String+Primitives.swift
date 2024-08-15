import Foundation

public extension Character {
    static let space: Character = " "
}

public extension String {
    static let zero = "0"
    static let empty = ""
    
    var remove0x: String {
        if self.count >= 2 && starts(with: "0x") {
            return String(self.dropFirst(2))
        }
        return self
    }

    var append0x: String {
        if starts(with: "0x") {
            return self
        }
        return "0x" + self
    }
    
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func truncate(
        first: Int = 6,
        last: Int = 4,
        connector: String = "..."
    ) -> String {
        return self.replacingOccurrences(of: self.dropFirst(first).dropLast(last), with: connector)
    }
    
    func numberOfLines() -> Int {
        return self.numberOfOccurrencesOf(string: "\n") + 1
    }

    func numberOfOccurrencesOf(string: String) -> Int {
        return self.components(separatedBy:string).count - 1
    }
    
    func trim() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func addPadding(number: Int, padding: Character) -> String {
        return String(repeatElement(padding, count: number - self.count)) + self
    }
}

extension Optional where Wrapped == String {
    public var valueOrEmpty: String {
        return self ?? .empty
    }
}
