import SwiftUI

// MARK: - Table header row
private struct InvoiceColHeader: View {
    @EnvironmentObject var loc: LocalizationManager
    var body: some View {
        HStack(spacing: 0) {
            Text(loc.t("Số HĐ")).frame(width: 90, alignment: .leading)
            Text(loc.t("Khách hàng")).frame(maxWidth: .infinity, alignment: .leading)
            Text(loc.t("Ngày")).frame(width: 100, alignment: .leading)
            Text(loc.t("Tổng tiền")).frame(width: 120, alignment: .trailing)
            Text(loc.t("Còn lại")).frame(width: 110, alignment: .trailing)
            Text(loc.t("Trạng thái")).frame(width: 120, alignment: .leading).padding(.leading, 16)
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

// MARK: - Single invoice row
struct InvoiceRow: View {
    @ObservedObject var invoice: Invoice
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 0) {
            // Status dot + invoice number
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.statusColor(invoice.status))
                    .frame(width: 6, height: 6)
                Text(invoice.invoiceNumber)
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundColor(.appText1)
            }
            .frame(width: 90, alignment: .leading)

            // Client name
            VStack(alignment: .leading, spacing: 1) {
                Text(invoice.clientName.isEmpty ? "—" : invoice.clientName)
                    .font(.system(size: 13))
                    .foregroundColor(.appText1)
                    .lineLimit(1)
                if !invoice.clientEmail.isEmpty {
                    Text(invoice.clientEmail)
                        .font(.system(size: 11))
                        .foregroundColor(.appText3)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Date
            Text(invoice.invoiceDate.formattedString())
                .font(.system(size: 12))
                .foregroundColor(.appText2)
                .frame(width: 100, alignment: .leading)

            // Total
            Text(formatVND(invoice.totalAmount))
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.appText1)
                .frame(width: 120, alignment: .trailing)

            // Remaining
            let remaining = invoice.remainingAmount
            Text(remaining > 0 ? formatVND(remaining) : "—")
                .font(.system(size: 12))
                .foregroundColor(remaining > 0 ? .appOrange : .appText3)
                .frame(width: 110, alignment: .trailing)

            // Status badge
            StatusBadge(status: invoice.status)
                .frame(width: 120, alignment: .leading)
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
                } else if invoice.isOverdue {
                    Color.appRed.opacity(0.05)
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

// MARK: - InvoiceTableView
struct InvoiceTableView: View {
    let invoices: [Invoice]
    @Binding var selectedInvoice: Invoice?
    @EnvironmentObject var loc: LocalizationManager

    var body: some View {
        VStack(spacing: 0) {
            InvoiceColHeader()
            GlassDivider()

            if invoices.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 36))
                        .foregroundColor(.appText3)
                    Text(loc.t("Không tìm thấy hóa đơn"))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.appText2)
                    Text(loc.t("Nhấn \"Tạo mới\" để thêm hóa đơn đầu tiên"))
                        .font(.system(size: 12))
                        .foregroundColor(.appText3)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(invoices) { inv in
                            InvoiceRow(invoice: inv, isSelected: selectedInvoice?.id == inv.id)
                                .onTapGesture { selectedInvoice = inv }
                            GlassDivider()
                        }
                    }
                }
            }
        }
    }
}
