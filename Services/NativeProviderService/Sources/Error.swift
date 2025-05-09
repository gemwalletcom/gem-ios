// Copyright (c). Gem Wallet. All rights reserved.
import Foundation
import Gemstone

public func inspectError(response: URLResponse, data: Data) throws {
    guard
        let httpResponse = (response as? HTTPURLResponse)
    else {
        throw AlienError.ResponseError(msg: "Invalid HTTP Response")
    }
    let statusCode = httpResponse.statusCode
    if statusCode != 200 {
        let data = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        if let error = data?["error"] as? String {
            // Check {"error": "message"}
            throw AlienError.ResponseError(msg: "Server error: \(error)")
        } else if let error = data?["error"] as? [String: Any], let message = error["message"] as? String {
            // Check {"jsonrpc": "2.0", "error": {"code": -32700, "message": "Parse error"}, "id": null}
            throw AlienError.ResponseError(msg: "JSONRPC error: \(message)")
        }
        throw AlienError.ResponseError(msg: "HTTP status code: \(statusCode)")
    }
}
