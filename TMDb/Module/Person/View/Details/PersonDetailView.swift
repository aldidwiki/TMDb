//
//  PersonDetailView.swift
//  TMDb
//

import SDWebImageSwiftUI
import SwiftUI

struct PersonDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var presenter: PersonPresenter
    @State private var isBiographyAboveViewport = false

    private enum ScrollAnchor {
        case biography
    }

    private let personId: Int
    private let router = PersonRouter()

    init(personUseCase: PersonUseCase, personId: Int, favoriteUseCase: FavoriteUseCase = Injection().provideFavoriteUseCase()) {
        _presenter = State(initialValue: PersonPresenter(personUseCase: personUseCase, favoriteUseCase: favoriteUseCase))
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
        .onAppear { presenter.checkFavoriteStatus(personId: personId) }
        .alert("Couldn’t update favorites", isPresented: $presenter.showsFavoriteError) {
            Button("OK", role: .cancel) {}
        }
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
        ScrollViewReader { scroll in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    insetContent { overview }
                    let links = presenter.profileLinks
                    if !links.isEmpty {
                        insetContent { externalLinks(links) }
                    }
                    insetContent {
                        PersonBiography(text: presenter.person.biography) {
                            if isBiographyAboveViewport {
                                scroll.scrollTo(ScrollAnchor.biography, anchor: .top)
                            }
                        }
                    }
                    .id(ScrollAnchor.biography)
                    .onGeometryChange(for: Bool.self) {
                        $0.frame(in: .scrollView(axis: .vertical)).minY < 0
                    } action: { isBiographyAboveViewport = $0 }
                    insetContent { personalInfo }
                    knownFor
                }
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
        }
    }

    private var overview: some View {
        HStack(spacing: 16) {
            NavigationLink {
                router.makePersonImageView(personId: personId, personName: presenter.person.name)
            } label: {
                PersonArtwork(
                    path: presenter.person.profilePath,
                    baseURL: API.profileImageBaseUrl,
                    fallback: DashboardDesign.surfaceDim,
                    width: 120,
                    height: 180,
                    radius: DashboardDesign.cardRadius
                )
                .accessibilityLabel("View profile photos")
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 12) {
                Text(presenter.person.name)
                    .font(.title.bold())
                    .foregroundStyle(DashboardDesign.text)
                    .accessibilityAddTraits(.isHeader)
                    .fixedSize(horizontal: false, vertical: true)

                if let department = presenter.person.knownFor.nonPlaceholderText {
                    Text(department == "Acting" ? "Actor" : department)
                        .font(.subheadline)
                        .foregroundStyle(DashboardDesign.secondaryText)
                }

                favoriteButton
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var favoriteButton: some View {
        AnimatedFavoriteButton(isFavorite: presenter.isFavorite) {
            let previousValue = presenter.isFavorite
            presenter.toggleFavorite()
            return previousValue != presenter.isFavorite
        }
        .frame(maxWidth: 170)
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

    @ViewBuilder
    private var personalInfo: some View {
        let department = presenter.person.knownFor.nonPlaceholderText
        let birthday = presenter.person.birthday.formatDateString().nonPlaceholderText
        let birthplace = presenter.person.birthplace.nonPlaceholderText
        let aliases = presenter.person.alsoKnownAs.compactMap(\.nonPlaceholderText)

        if department != nil || birthday != nil || birthplace != nil || !aliases.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                sectionTitle("Personal info")
                VStack(alignment: .leading, spacing: 16) {
                    if department != nil || birthday != nil {
                        HStack(alignment: .top, spacing: 16) {
                            if let department {
                                infoField("Known for", value: department)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            if let birthday {
                                infoField("Date of birth", value: birthday)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            if department == nil || birthday == nil {
                                Color.clear.frame(maxWidth: .infinity, maxHeight: 0)
                            }
                        }
                    }
                    if let birthplace { infoField("Place of birth", value: birthplace) }

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
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        sectionTitle("Known for")
                        Spacer()
                        NavigationLink {
                            router.makePersonCreditsView(
                                personName: presenter.person.name,
                                items: presenter.allCreditItems
                            )
                        } label: {
                            Label("See All", systemImage: "arrow.right")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(DashboardDesign.accent)
                                .padding(.horizontal, 12)
                                .frame(minHeight: 30)
                                .background(
                                    DashboardDesign.surfaceDim,
                                    in: RoundedRectangle(cornerRadius: DashboardDesign.controlRadius)
                                )
                        }
                        .buttonStyle(.plain)
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
                            } label: {
                                PersonKnownForCard(credit: item.credit)
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

}

private struct PersonOutlineControl: ViewModifier {
    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: DashboardDesign.controlRadius)

        content
            .font(.footnote.weight(.semibold))
            .foregroundStyle(DashboardDesign.accent)
            .padding(.horizontal, 10)
            .frame(minHeight: 44)
            .background(DashboardDesign.surface, in: shape)
            .overlay {
                shape
                    .strokeBorder(DashboardDesign.border)
                    .allowsHitTesting(false)
            }
    }
}

#if DEBUG
#Preview("Person detail") {
    NavigationStack {
        PersonDetailView(personUseCase: PreviewFixtures.UseCases(), personId: PreviewFixtures.person.id, favoriteUseCase: PreviewFixtures.favorites())
    }
}
#endif
