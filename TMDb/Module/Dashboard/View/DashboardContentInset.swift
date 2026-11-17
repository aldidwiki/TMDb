import SwiftUI

struct DashboardContentInset: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: DashboardDesign.contentWidth, alignment: .leading)
            .padding(.horizontal, DashboardDesign.contentInset)
            .frame(maxWidth: .infinity)
    }
}
