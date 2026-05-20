import SwiftUI

private struct ClientColHeader: View {
    @EnvironmentObject var loc: LocalizationManager
    var body: some View {
        HStack(spacing: 0) {
            Text(loc.t("Công ty / Tên")).frame(maxWidth: .infinity, alignment: .leading)
            Text("Email").frame(width: 180, alignment: .leading)
            Text(loc.t("Điện thoại")).frame(width: 120, alignment: .leading)
            Text(loc.t("Doanh thu")).frame(width: 120, alignment: .trailing)
            Text(loc.t("Hạn mức còn")).frame(width: 120, alignment: .trailing)
            Text(loc.t("Trạng thái")).frame(width: 110, alignment: .leading).padding(.leading, 16)
        }
        .font(.system(size: 10, weight: .semibold))
        .foregroundColor(.appText3)
        .tracking(0.8)
        .textCase(.uppercase)
        .padding(.horizontal, 20).padding(.vertical, 8)
        .background(
            ZStack {
                VisualEffectBlur(material: .hudWindow, blendingMode: .withinWindow)
                Color.white.opacity(0.03)
            }
        )
    }
}

struct ClientRow: View {
    @ObservedObject var client: Client
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 0) {
            // Name + company
            VStack(alignment: .leading, spacing: 2) {
                Text(client.displayName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.appText1)
                    .lineLimit(1)
                if !client.companyName.isEmpty && client.companyName != client.name {
                    Text(client.name)
                        .font(.system(size: 11))
                        .foregroundColor(.appText3)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(client.email.isEmpty ? "—" : client.email)
                .font(.system(size: 12))
                .foregroundColor(.appText2)
                .lineLimit(1)
                .frame(width: 180, alignment: .leading)

            Text(client.phone.isEmpty ? "—" : client.phone)
                .font(.system(size: 12))
                .foregroundColor(.appText2)
                .frame(width: 120, alignment: .leading)

            Text(formatVND(client.totalRevenue))
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.appGreen)
                .frame(width: 120, alignment: .trailing)

            let avail = client.creditAvailable
            Text(client.creditLimit > 0 ? formatVND(avail) : "—")
                .font(.system(size: 12))
                .foregroundColor(avail < client.creditLimit * 0.2 ? .appRed : .appText2)
                .frame(width: 120, alignment: .trailing)

            StatusBadge(status: client.status)
                .frame(width: 110, alignment: .leading)
                .padding(.leading, 16)
        }
        .padding(.horizontal, 20).padding(.vertical, 11)
        .background(
            Group {
                if isSelected {
                    ZStack {
                        VisualEffectBlur(material: .hudWindow, blendingMode: .withinWindow)
                        Color.appIndigo.opacity(0.14)
                    }
                } else {
                    Color.clear
                }
            }
        )
        .contentShape(Rectangle())
    }

    private func formatVND(_ v: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal; f.maximumFractionDigits = 0
        return (f.string(from: NSNumber(value: v)) ?? "0") + "₫"
    }
}

struct ClientsTableView: View {
    let clients: [Client]
    @Binding var selectedClient: Client?
    @EnvironmentObject var loc: LocalizationManager

    var body: some View {
        VStack(spacing: 0) {
            ClientColHeader()
            GlassDivider()

            if clients.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "person.2.slash")
                        .font(.system(size: 36))
                        .foregroundColor(.appText3)
                    Text(loc.t("Không tìm thấy khách hàng"))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.appText2)
                    Text(loc.t("Nhấn \"Tạo mới\" để thêm khách hàng đầu tiên"))
                        .font(.system(size: 12))
                        .foregroundColor(.appText3)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(clients) { cl in
                            ClientRow(client: cl, isSelected: selectedClient?.id == cl.id)
                                .onTapGesture { selectedClient = cl }
                            GlassDivider()
                        }
                    }
                }
            }
        }
    }
}
