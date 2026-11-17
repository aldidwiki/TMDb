import Foundation

extension String {
    func formatDateString(input inFormat: String = "yyyy-MM-dd", output outFormat: String = "dd MMMM yyyy") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = inFormat
        guard let outDate = dateFormatter.date(from: self) else {
            return ""
        }

        dateFormatter.dateFormat = outFormat
        return dateFormatter.string(from: outDate)
    }
}
