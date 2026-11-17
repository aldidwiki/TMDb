//
//  ExpandableTextView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 11/09/23.
//

import SwiftUI

struct ExpandableTextView: View {
    var textData: String
    var maxTextLine = 3
    var onCollapse: () -> Void = {}

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isExpanded = false
    @State private var collapsedHeight: CGFloat = 0
    @State private var expandedHeight: CGFloat = 0

    private var canExpand: Bool {
        collapsedHeight > 0 && expandedHeight > collapsedHeight + 0.5
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            textContent

            if canExpand {
                Button {
                    toggleExpansion()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.down")
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                            .accessibilityHidden(true)
                        Text(isExpanded ? "Collapse" : "Expand")
                            .contentTransition(.identity)
                    }
                    .font(.system(size: 14))
                    .fontWeight(.medium)
                }
                .buttonStyle(.borderless)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .onChange(of: textData) { _, _ in isExpanded = false }
    }

    private var textContent: some View {
        TextRevealLayout(progress: isExpanded ? 1 : 0) {
            text(lineLimit: maxTextLine)
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { collapsedHeight = $0 }
                .accessibilityHidden(isExpanded)
            text(lineLimit: nil)
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { expandedHeight = $0 }
                .accessibilityHidden(!isExpanded)
        }
        .clipped()
    }

    private func toggleExpansion() {
        withAnimation(reduceMotion ? nil : .smooth(duration: 0.48)) {
            isExpanded.toggle()
            if !isExpanded {
                onCollapse()
            }
        }
    }

    private func text(lineLimit: Int?) -> some View {
        Text(textData)
            .multilineTextAlignment(.leading)
            .lineLimit(lineLimit)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct TextRevealLayout: Layout {
    var progress: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let textProposal = ProposedViewSize(width: proposal.width, height: nil)
        let collapsed = subviews[0].sizeThatFits(textProposal)
        let expanded = subviews[1].sizeThatFits(textProposal)
        let fraction = min(max(progress, 0), 1)
        return CGSize(
            width: max(collapsed.width, expanded.width),
            height: collapsed.height + (expanded.height - collapsed.height) * fraction
        )
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let textProposal = ProposedViewSize(width: bounds.width, height: nil)
        let top = CGPoint(x: bounds.minX, y: bounds.minY)
        let clipped = CGPoint(x: bounds.minX, y: bounds.maxY)

        // Reveal the full text through the clip. The collapsed layout supplies the ellipsis at rest.
        subviews[0].place(at: progress <= 0 ? top : clipped, anchor: .topLeading, proposal: textProposal)
        subviews[1].place(at: progress > 0 ? top : clipped, anchor: .topLeading, proposal: textProposal)
    }
}

#Preview("Truncated text") {
    ExpandableTextView(
        textData: "Robb goes to war against the Lannisters. Jon finds himself struggling on deciding if his place is with Robb or the Night's Watch. Drogo has fallen ill from a fresh battle wound. Daenerys is desperate to save him."
    )
    .font(.subheadline)
    .lineSpacing(3)
    .frame(width: 280)
    .padding()
}

#Preview("Text that fits") {
    ExpandableTextView(textData: "A short biography that fits without truncating.")
        .font(.subheadline)
        .lineSpacing(3)
        .frame(width: 280)
        .padding()
}
