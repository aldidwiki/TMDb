import SwiftUI

struct DetailCastCard: View {
    let credit: CreditModel

    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            DetailCastAvatar(credit: credit, diameter: 56)

            VStack(alignment: .center, spacing: 2) {
                Text(credit.name)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DashboardDesign.text)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)

                if !credit.characterName.isEmpty {
                    Text(credit.characterName)
                        .font(.caption2)
                        .foregroundStyle(DashboardDesign.secondaryText)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                }
            }
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(width: 132, height: 136, alignment: .top)
        .background(DashboardDesign.surface, in: RoundedRectangle(cornerRadius: DashboardDesign.cardRadius))
        .overlay {
            RoundedRectangle(cornerRadius: DashboardDesign.cardRadius)
                .strokeBorder(DashboardDesign.border)
                .allowsHitTesting(false)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview("DetailCastCard") {
    DetailCastCard(credit: PreviewFixtures.credit)
}
#endif
