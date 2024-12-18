import Foundation

extension String {
    func leftPadded(to length: Int) -> String {
        let padding = max(0, length - self.count)
        return String(repeating: "0", count: padding) + self
    }
}
