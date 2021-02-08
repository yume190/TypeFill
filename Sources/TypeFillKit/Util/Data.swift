import Foundation

extension String {
    var utf8: Data? {
        return self.data(using: .utf8)
    }
}

extension Data {
    var utf8: String? {
        return String(data: self, encoding: .utf8)
    }
}
