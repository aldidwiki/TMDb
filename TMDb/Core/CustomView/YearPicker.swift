import SwiftUI

struct YearPicker: View {
    private enum Mode: String, CaseIterable {
        case single = "Single year"
        case range = "Year range"
    }

    private enum Field: Hashable {
        case single, from, to
    }

    let title: String
    let onCancel: () -> Void
    let onUse: (YearFilter?) -> Void

    @State private var mode: Mode = .single
    @State private var singleText = ""
    @State private var fromText = ""
    @State private var toText = ""
    @State private var anyYear = false
    @FocusState private var focusedField: Field?
    @ScaledMetric(relativeTo: .body) private var contentHeight = 455

    private let recentYears: [Int]
    private static let yearLength = 4

    init(title: String, selection: YearFilter?, onCancel: @escaping () -> Void,
         onUse: @escaping (YearFilter?) -> Void) {
        self.title = title
        self.onCancel = onCancel
        self.onUse = onUse

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .autoupdatingCurrent
        let currentYear = calendar.component(.year, from: .now)
        recentYears = (0..<5).map { currentYear - $0 }

        switch selection {
        case .single(let year):
            _singleText = State(initialValue: String(year))
        case .range(let years):
            _mode = State(initialValue: .range)
            _fromText = State(initialValue: String(years.lowerBound))
            _toText = State(initialValue: String(years.upperBound))
        case nil:
            break
        }
    }

    private var selection: YearFilter? {
        switch mode {
        case .single:
            return year(from: singleText).map(YearFilter.single)
        case .range:
            guard let from = year(from: fromText), let to = year(from: toText), from <= to else {
                return nil
            }
            return .range(from...to)
        }
    }

    private var canUseSelection: Bool {
        selection != nil || (mode == .single && anyYear)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Capsule()
                .fill(DashboardDesign.border)
                .frame(width: 48, height: 4)
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    header
                    HStack(spacing: 12) {
                        ForEach(Mode.allCases, id: \.self, content: modeButton)
                    }

                    if mode == .single {
                        yearField("Type a year", placeholder: "e.g. 2024", text: $singleText, field: .single)
                            .onChange(of: singleText) { _, newValue in
                                if !newValue.isEmpty { anyYear = false }
                            }
                        recentOptions
                    } else {
                        HStack(alignment: .top, spacing: 12) {
                            yearField("From", placeholder: "2000", text: $fromText, field: .from)
                            yearField("To", placeholder: "2024", text: $toText, field: .to)
                        }
                        Text("Enter four-digit years. From cannot exceed To.")
                            .font(.caption)
                            .foregroundStyle(DashboardDesign.secondaryText)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: contentHeight)
            .scrollDismissesKeyboard(.interactively)

            HStack(spacing: 12) {
                DrawerActionButton(title: "Cancel", prominent: false, action: onCancel)
                DrawerActionButton(title: "Use this year", prominent: true) {
                    onUse(selection)
                }
                .disabled(!canUseSelection)
            }
        }
        .frame(maxWidth: DashboardDesign.contentWidth)
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background {
            UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24)
                .fill(DashboardDesign.surface)
                .ignoresSafeArea(edges: [.horizontal, .bottom])
        }
        .accessibilityElement(children: .contain)
        .accessibilityAction(.escape, onCancel)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(title)
                    .font(.title3.bold())
                    .foregroundStyle(DashboardDesign.text)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .foregroundStyle(DashboardDesign.secondaryText)
                        .frame(width: 44, height: 36)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close")
            }
            Text("Choose a year or a year range.")
                .font(.footnote)
                .foregroundStyle(DashboardDesign.secondaryText)
        }
    }

    private func modeButton(_ option: Mode) -> some View {
        let selected = mode == option
        let shape = RoundedRectangle(cornerRadius: DashboardDesign.controlRadius)

        return Button {
            focusedField = nil
            mode = option
        } label: {
            Text(option.rawValue)
                .font(.footnote.weight(.semibold))
                .multilineTextAlignment(.center)
                .foregroundStyle(selected ? DashboardDesign.surface : DashboardDesign.accent)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity, minHeight: 36)
                .background(selected ? DashboardDesign.accent : DashboardDesign.background, in: shape)
                .overlay { shape.strokeBorder(selected ? .clear : DashboardDesign.border) }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private func yearField(_ title: String, placeholder: String, text: Binding<String>, field: Field) -> some View {
        let shape = RoundedRectangle(cornerRadius: DashboardDesign.controlRadius)

        return VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .accessibilityHidden(true)
            TextField(title, text: text, prompt: Text(placeholder).foregroundStyle(DashboardDesign.secondaryText))
                .keyboardType(.numberPad)
                .focused($focusedField, equals: field)
                .onChange(of: text.wrappedValue) { _, value in
                    if value.count > Self.yearLength {
                        text.wrappedValue = String(value.prefix(Self.yearLength))
                    }
                }
                .padding(.horizontal, 14)
                .frame(minHeight: 48)
                .background(DashboardDesign.background, in: shape)
                .overlay {
                    shape.strokeBorder(focusedField == field ? DashboardDesign.accent : DashboardDesign.border)
                        .allowsHitTesting(false)
                }
        }
        .foregroundStyle(DashboardDesign.text)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var recentOptions: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Recent years")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(DashboardDesign.text)
                .accessibilityAddTraits(.isHeader)
            VStack(spacing: 2) {
                yearOption(nil)
                ForEach(recentYears, id: \.self) { yearOption($0) }
            }
        }
    }

    private func yearOption(_ option: Int?) -> some View {
        let selected = option.map { year(from: singleText) == $0 } ?? anyYear

        return Button {
            focusedField = nil
            singleText = option.map(String.init) ?? ""
            anyYear = option == nil
        } label: {
            HStack {
                Text(option.map(String.init) ?? "Any year")
                Spacer()
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selected ? DashboardDesign.accent : DashboardDesign.secondaryText)
                    .accessibilityHidden(true)
            }
            .font(.subheadline)
            .foregroundStyle(selected ? DashboardDesign.accent : DashboardDesign.text)
            .padding(.horizontal, 14)
            .frame(minHeight: 34)
            .background(selected ? DashboardDesign.surfaceDim : DashboardDesign.surface, in: RoundedRectangle(cornerRadius: 8))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private func year(from text: String) -> Int? {
        guard text.count == Self.yearLength, let year = Int(text), (1000...9999).contains(year) else { return nil }
        return year
    }
}

struct DrawerActionButton: View {
    let title: String
    let prominent: Bool
    let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: DashboardDesign.controlRadius)
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .multilineTextAlignment(.center)
                .foregroundStyle(prominent ? DashboardDesign.surface : DashboardDesign.accent)
                .padding(8)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(prominent ? DashboardDesign.accent : DashboardDesign.surface, in: shape)
                .overlay { shape.strokeBorder(prominent ? Color.clear : DashboardDesign.border) }
        }
        .buttonStyle(.plain)
        .opacity(isEnabled ? 1 : 0.45)
    }
}
