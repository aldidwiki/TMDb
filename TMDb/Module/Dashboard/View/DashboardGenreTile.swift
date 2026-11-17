import SwiftUI

struct DashboardGenreTile: View {
    let genre: DashboardPresenter.GenreTile

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(genre.monogram)
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(DashboardDesign.color(genre.accent))
                .frame(width: 24, height: 24)
                .background(DashboardDesign.color(genre.accent).opacity(0.12), in: Circle())
                .accessibilityHidden(true)

            Text(genre.name)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(DashboardDesign.text)
                .lineLimit(2)
        }
        .padding(.horizontal, 10)
        .padding(.top, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 78, alignment: .topLeading)
        .background(DashboardDesign.color(genre.background), in: RoundedRectangle(cornerRadius: 14))
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview("DashboardGenreTile") {
    DashboardGenreTile(genre: PreviewFixtures.genreTile)
        .frame(width: 110)
}
#endif
