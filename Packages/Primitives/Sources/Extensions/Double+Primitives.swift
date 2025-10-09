import Foundation

extension Double {
    
    public static func from(string: String) throws -> Double {
        guard let value = Double(string) else {
            throw AnyError("invalid double")
        }
        return value
    }
    
    public func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
