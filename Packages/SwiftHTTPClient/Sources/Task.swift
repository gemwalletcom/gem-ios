import Foundation

public enum Task {
    case plain
    case params([String: Any])
    case encodable(Encodable)
    case data(Data)
}
