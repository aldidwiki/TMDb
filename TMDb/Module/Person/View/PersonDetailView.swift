//
//  PersonDetailView.swift
//  TMDb
//

import SDWebImageSwiftUI
import SwiftUI

struct PersonDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var presenter: PersonPresenter

    private let personId: Int
    private let router = PersonRouter()
    private let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]

    init(personUseCase: PersonUseCase, personId: Int) {
        _presenter = State(initialValue: PersonPresenter(personUseCase: personUseCase))
        self.personId = personId
    }

    var body: some View {
        Group {
            if !presenter.errorMessage.isEmpty {
                ContentUnavailableView {
                    Label(presenter.errorMessage, systemImage: "wifi.exclamationmark")
                } actions: {
                    Button("Retry") { presenter.getPerson(personId: personId) }
                }
            } else if presenter.person.id == personId && personId > 0 {
                details
            } else {
                ProgressView("Loading person details")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DashboardDesign.background.ignoresSafeArea())
        .safeAreaInset(edge: .top, spacing: 0) { header }
        .toolbar(.hidden, for: .navigationBar)
        .tint(DashboardDesign.accent)
        .task {
            if presenter.person.id != personId && presenter.errorMessage.isEmpty {
                presenter.getPerson(personId: personId)
            }
        }
    }

    private var header: some View {
        insetContent {
            HStack(spacing: 0) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(width: 44, height: 44, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Back")

                Text("Person Details")
                    .font(.title3.bold())
                    .accessibilityAddTraits(.isHeader)
            }
            .foregroundStyle(DashboardDesign.text)
            .frame(minHeight: 56)
        }
        .background(DashboardDesign.background)
    }

    private var details: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                insetContent {
                    overview
                }
                let links = presenter.profileLinks
                if !links.isEmpty {
                    insetContent { externalLinks(links) }
                }
                insetContent { biography }
                insetContent { personalInfo }
                knownFor
            }
            .padding(.top, 8)
            .padding(.bottom, 28)
        }
    }

    private var overview: some View {
        HStack(spacing: 16) {
            presenter.toPersonImageView(personId: personId) {
                artwork(
                    path: presenter.person.profilePath,
                    baseURL: API.profileImageBaseUrl,
                    fallback: DashboardDesign.surfaceDim,
                    width: 120,
                    height: 180,
                    radius: DashboardDesign.cardRadius
                )
                .accessibilityLabel("View profile photos")
            }

            VStack(alignment: .leading, spacing: 12) {
                Text(presenter.person.name)
                    .font(.title.bold())
                    .foregroundStyle(DashboardDesign.text)
                    .accessibilityAddTraits(.isHeader)
                    .fixedSize(horizontal: false, vertical: true)

                if let department = availableText(presenter.person.knownFor) {
                    Text(department == "Acting" ? "Actor" : department)
                        .font(.subheadline)
                        .foregroundStyle(DashboardDesign.secondaryText)
                }

                Button {} label: {
                    Label("Favorite", systemImage: "heart")
                        .frame(maxWidth: .infinity)
                        .modifier(PersonOutlineControl())
                }
                .buttonStyle(.plain)
                .disabled(true)
                .frame(maxWidth: 170)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func externalLinks(_ links: [PersonPresenter.ProfileLink]) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 8) {
                ForEach(links) { link in
                    externalLink(link)
                }
            }
            VStack(spacing: 8) {
                ForEach(links) { link in
                    externalLink(link)
                }
            }
        }
    }

    private func externalLink(_ link: PersonPresenter.ProfileLink) -> some View {
        Link(destination: link.url) {
            HStack(spacing: 4) {
                Text(link.title)
                Image(systemName: "arrow.up.right")
                    .font(.caption2.weight(.semibold))
                    .accessibilityHidden(true)
            }
            .fixedSize(horizontal: true, vertical: false)
            .frame(maxWidth: .infinity)
            .modifier(PersonOutlineControl())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(link.title == "Google" ? "Google Search" : link.title)
    }

    private var biography: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Biography")
            if let biography = availableText(presenter.person.biography) {
                ExpandableTextView(textData: biography, maxTextLine: 7)
                    .font(.subheadline)
                    .foregroundStyle(DashboardDesign.secondaryText)
                    .lineSpacing(3)
            } else {
                Text("Biography unavailable")
                    .font(.subheadline)
                    .foregroundStyle(DashboardDesign.secondaryText)
            }
        }
    }

    @ViewBuilder
    private var personalInfo: some View {
        let department = availableText(presenter.person.knownFor)
        let birthday = availableText(presenter.person.birthday.formatDateString())
        let birthplace = availableText(presenter.person.birthplace)
        let aliases = presenter.person.alsoKnownAs.compactMap(availableText)

        if department != nil || birthday != nil || birthplace != nil || !aliases.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                sectionTitle("Personal info")
                VStack(alignment: .leading, spacing: 16) {
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
                        if let department { infoField("Known for", value: department) }
                        if let birthday { infoField("Date of birth", value: birthday) }
                        if let birthplace { infoField("Place of birth", value: birthplace) }
                    }

                    if !aliases.isEmpty {
                        infoField("Also known as", value: aliases.joined(separator: ", "))
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(DashboardDesign.surface, in: RoundedRectangle(cornerRadius: DashboardDesign.cardRadius))
                .overlay {
                    RoundedRectangle(cornerRadius: DashboardDesign.cardRadius)
                        .strokeBorder(DashboardDesign.border)
                        .allowsHitTesting(false)
                }
            }
        }
    }

    private func infoField(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(DashboardDesign.secondaryText)
            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(DashboardDesign.text)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    private var knownFor: some View {
        let items = presenter.knownForItems

        return VStack(alignment: .leading, spacing: 8) {
            insetContent {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        sectionTitle("Known for")
                        Spacer()
                        Button {} label: {
                            Label("See All", systemImage: "arrow.right")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(DashboardDesign.accent)
                                .padding(.horizontal, 12)
                                .frame(minHeight: 44)
                                .background(
                                    DashboardDesign.surfaceDim,
                                    in: RoundedRectangle(cornerRadius: DashboardDesign.controlRadius)
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(true)
                    }

                    Text(items.isEmpty ? "No credits available" : "Top 10 · Movies & TV shows")
                        .font(.caption)
                        .foregroundStyle(DashboardDesign.secondaryText)
                }
            }

            if !items.isEmpty {
                ScrollView(.horizontal) {
                    LazyHStack(alignment: .top, spacing: 12) {
                        ForEach(items) { item in
                            NavigationLink {
                                router.destination(for: item.id)
                                    .toolbar(.visible, for: .navigationBar)
                            } label: {
                                creditCard(item.credit)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .contentMargins(.horizontal, DashboardDesign.contentInset, for: .scrollContent)
                .scrollIndicators(.hidden)
            }
        }
    }

    private func creditCard(_ credit: CreditModel) -> some View {
        let isMovie = credit.mediaType == Constants.movieResponseType
        let media = isMovie ? "Movie" : "TV"
        let role = availableText(credit.characterName)

        return VStack(alignment: .leading, spacing: 4) {
            artwork(
                path: credit.profilePath,
                baseURL: API.imageBaseUrl,
                fallback: DashboardDesign.color(isMovie ? 0x493255 : 0x1C5060),
                width: 140,
                height: 210,
                radius: DashboardDesign.controlRadius
            )
            .accessibilityHidden(true)

            Text(credit.name)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(DashboardDesign.text)
                .lineLimit(1)

            Text(role.map { "\($0) · \(media)" } ?? media)
                .font(.caption)
                .foregroundStyle(DashboardDesign.secondaryText)
                .lineLimit(1)
        }
        .frame(width: 140, alignment: .leading)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }

    private func artwork(path: String, baseURL: String, fallback: Color, width: CGFloat, height: CGFloat, radius: CGFloat) -> some View {
        ZStack {
            fallback
            if let path = availableText(path) {
                WebImage(url: URL(string: baseURL + path))
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: radius))
    }

    private func insetContent<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(maxWidth: DashboardDesign.contentWidth, alignment: .leading)
            .padding(.horizontal, DashboardDesign.contentInset)
            .frame(maxWidth: .infinity)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.title3.bold())
            .foregroundStyle(DashboardDesign.text)
            .accessibilityAddTraits(.isHeader)
    }

    private func availableText(_ value: String) -> String? {
        let text = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty || text == "-" ? nil : text
    }
}

private struct PersonOutlineControl: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.footnote.weight(.semibold))
            .foregroundStyle(DashboardDesign.accent)
            .padding(.horizontal, 10)
            .frame(minHeight: 44)
            .background(DashboardDesign.surface, in: RoundedRectangle(cornerRadius: DashboardDesign.controlRadius))
            .overlay {
                RoundedRectangle(cornerRadius: DashboardDesign.controlRadius)
                    .strokeBorder(DashboardDesign.border)
                    .allowsHitTesting(false)
            }
    }
}

#Preview {
    NavigationStack {
        PersonDetailView(personUseCase: Injection().providePersonUseCase(), personId: 933238)
    }
}
