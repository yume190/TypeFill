import Foundation

extension String {
    var utf8: Data? {
        return self.data(using: .utf8)
    }
}

extension Data {
    var string: String? {
        return String(data: self, encoding: .utf8)
    }
}