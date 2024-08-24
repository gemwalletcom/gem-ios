import Foundation

public enum RequestData {
    case plain
    case params([String: Any])
    case encodable(Encodable)
    case data(Data)
}
