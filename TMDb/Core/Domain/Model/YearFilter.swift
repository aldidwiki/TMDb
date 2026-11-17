enum YearFilter: Equatable {
    case single(Int)
    case range(ClosedRange<Int>)

    var label: String {
        switch self {
        case .single(let year): String(year)
        case .range(let years): "\(years.lowerBound)–\(years.upperBound)"
        }
    }

    var dates: ClosedRange<String> {
        let years: ClosedRange<Int>
        switch self {
        case .single(let year): years = year...year
        case .range(let range): years = range
        }
        return "\(years.lowerBound)-01-01"..."\(years.upperBound)-12-31"
    }
}
