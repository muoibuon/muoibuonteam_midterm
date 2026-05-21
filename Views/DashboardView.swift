import SwiftUI

struct DashboardView: View {
    @FetchRequest(entity: Invoice.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Invoice.createdAt, ascending: false)])
    var invoices: FetchedResults<Invoice>

    @FetchRequest(entity: Client.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Client.companyName, ascending: true)])
    var clients: FetchedResults<Client>

    @EnvironmentObject var api: APIService
    @EnvironmentObject var loc: LocalizationManager

    private var totalRevenue: Double   { invoices.filter { $0.paymentStatus == "paid" }.reduce(0) { $0 + $1.totalAmount } }
    private var outstanding: Double    { invoices.filter { $0.paymentStatus != "paid" && $0.status != "cancelled" }.reduce(0) { $0 + $1.remainingAmount } }
    private var overdueCount: Int      { invoices.filter { $0.isOverdue }.count }
    private var recentInvoices: [Invoice] { Array(invoices.prefix(8)) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dashboard")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.appText1)
                    Text(loc.t("Tổng quan hoạt động kinh doanh"))
                        .font(.system(size: 13))
                        .foregroundColor(.appText3)
                }
                .padding(.top, 4)

                // Stat cards
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()),
                                    GridItem(.flexible()), GridItem(.flexible())],
                          spacing: 14) {
                    StatCard(title: loc.t("Doanh thu"),
                             value: formatVND(totalRevenue),
                             icon: "banknote.fill",
                             color: .appGreen,
                             trend: 12.4)
                    StatCard(title: loc.t("Chưa thu"),
                             value: formatVND(outstanding),
                             icon: "clock.badge.exclamationmark.fill",
                             color: .appOrange)
                    StatCard(title: loc.t("Quá hạn"),
                             value: "\(overdueCount) \(loc.t("HĐ"))",
                             icon: "exclamationmark.triangle.fill",
                             color: .appRed)
                    StatCard(title: loc.t("Khách hàng"),
                             value: "\(clients.count)",
                             icon: "person.2.fill",
                             color: .appIndigo)
                }

                // Two-column: recent invoices + currency rates
                HStack(alignment: .top, spacing: 16) {
                    // Recent invoices
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text(loc.t("Hóa đơn gần đây"))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.appText1)
                            Spacer()
                            Text("\(invoices.count) \(loc.t("tổng"))")
                                .font(.system(size: 12))
                                .foregroundColor(.appText3)
                        }
                        .padding(.horizontal, 16).padding(.vertical, 14)

                        GlassDivider()

                        if recentInvoices.isEmpty {
                            emptyState(icon: "doc.text", message: loc.t("Chưa có hóa đơn nào"))
                                .padding(.vertical, 32)
                        } else {
                            ForEach(recentInvoices) { inv in
                                recentInvoiceRow(inv)
                                GlassDivider()
                            }
                        }
                    }
                    .cardStyle()
                    .frame(maxWidth: .infinity)

                    // Currency rates widget
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text(loc.t("Tỷ giá hôm nay"))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.appText1)
                            Spacer()
                            if api.isLoadingRates {
                                ProgressView().scaleEffect(0.6)
                            } else {
                                Button {
                                    Task { await api.fetchExchangeRates() }
                                } label: {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 11))
                                        .foregroundColor(.appIndigo)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16).padding(.vertical, 14)

                        GlassDivider()

                        if api.rates.isEmpty && !api.isLoadingRates {
                            emptyState(icon: "network.slash", message: loc.t("Không thể tải tỷ giá"))
                                .padding(.vertical, 24)
                        } else {
                            ForEach(["USD", "EUR", "JPY", "SGD", "KRW"], id: \.self) { cur in
                                if let usdToVND = api.rates["VND"],
                                   let usdToCur = api.rates[cur], usdToCur > 0 {
                                    let rate = usdToVND / usdToCur
                                    rateRow(currency: cur, rate: rate)
                                    GlassDivider()
                                }
                            }
                        }

                        if let updated = api.lastRatesUpdate {
                            Text("\(loc.t("Cập nhật")): \(updated.formattedString(pattern: "HH:mm dd/MM"))")
                                .font(.system(size: 10))
                                .foregroundColor(.appText3)
                                .padding(.horizontal, 16).padding(.vertical, 10)
                        }
                    }
                    .cardStyle()
                    .frame(width: 260)
                }
            }
            .padding(24)
        }
        .background(Color.clear)
    }

    @ViewBuilder
    private func recentInvoiceRow(_ inv: Invoice) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.statusColor(inv.status))
                .frame(width: 7, height: 7)
            VStack(alignment: .leading, spacing: 2) {
                Text(inv.invoiceNumber)
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundColor(.appText1)
                Text(inv.clientName.isEmpty ? "—" : inv.clientName)
                    .font(.system(size: 11))
                    .foregroundColor(.appText3)
                    .lineLimit(1)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatVND(inv.totalAmount))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.appText1)
                StatusBadge(status: inv.status)
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
    }

    @ViewBuilder
    private func rateRow(currency: String, rate: Double) -> some View {
        HStack {
            Text(currency)
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundColor(.appText1)
                .frame(width: 40, alignment: .leading)
            Text(AppConstants.Currencies.symbols[currency] ?? currency)
                .font(.system(size: 11))
                .foregroundColor(.appText3)
            Spacer()
            let fmt = NumberFormatter()
            let _ = { fmt.numberStyle = .decimal; fmt.maximumFractionDigits = 0 }()
            Text("\(fmt.string(from: NSNumber(value: rate)) ?? "")₫")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.appIndigo)
        }
        .padding(.horizontal, 16).padding(.vertical, 11)
    }

    @ViewBuilder
    private func emptyState(icon: String, message: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.appText3)
            Text(message)
                .font(.system(size: 12))
                .foregroundColor(.appText3)
        }
        .frame(maxWidth: .infinity)
    }

    private func formatVND(_ v: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        return (f.string(from: NSNumber(value: v)) ?? "0") + "₫"
    }
}
