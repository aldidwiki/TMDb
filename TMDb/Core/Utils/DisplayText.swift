import Foundation

extension String {
    var nonPlaceholderText: String? {
        let text = trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty || text == "-" ? nil : text
    }
}
