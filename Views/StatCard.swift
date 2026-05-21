import SwiftUI

struct StatCard: View {
    let title:    String
    let value:    String
    let icon:     String
    let color:    Color
    var subtitle: String? = nil
    var trend:    Double? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                // Icon with glass pill
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color.opacity(0.18))
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(color.opacity(0.28), lineWidth: 1)
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(color)
                }
                .frame(width: 40, height: 40)

                Spacer()
                if let trend { trendBadge(trend) }
            }
            .padding(.bottom, 14)

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.appText1)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.appText2)
                .padding(.top, 3)

            if let sub = subtitle {
                Text(sub)
                    .font(.system(size: 11))
                    .foregroundColor(.appText3)
                    .padding(.top, 2)
            }
        }
        .padding(18)
        .glassCard(radius: 16, tint: color, tintOpacity: 0.03)
    }

    @ViewBuilder
    private func trendBadge(_ pct: Double) -> some View {
        let up = pct >= 0
        HStack(spacing: 3) {
            Image(systemName: up ? "arrow.up.right" : "arrow.down.right")
                .font(.system(size: 10, weight: .bold))
            Text("\(up ? "+" : "")\(String(format: "%.1f", pct))%")
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundColor(up ? .appGreen : .appRed)
        .padding(.horizontal, 7).padding(.vertical, 3)
        .background((up ? Color.appGreen : Color.appRed).opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .overlay(RoundedRectangle(cornerRadius: 5)
            .strokeBorder((up ? Color.appGreen : Color.appRed).opacity(0.25), lineWidth: 1))
    }
}
