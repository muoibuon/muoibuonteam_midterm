import SwiftUI

struct InvoiceListView: View {
    @FetchRequest(
        entity: Invoice.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Invoice.createdAt, ascending: false)]
    ) var invoices: FetchedResults<Invoice>

    @State private var selectedInvoice: Invoice?
    @State private var showingNewInvoice   = false
    @State private var searchText          = ""
    @State private var statusFilter        = "all"
    @EnvironmentObject var loc: LocalizationManager

    private let statusOptions = [
        ("all", "Tất cả"), ("draft", "Nháp"), ("pending", "Chờ xử lý"),
        ("paid", "Đã thanh toán"), ("cancelled", "Đã hủy")
    ]

    private var filtered: [Invoice] {
        var list = Array(invoices)
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            list = list.filter {
                $0.invoiceNumber.lowercased().contains(q) ||
                $0.clientName.lowercased().contains(q) ||
                $0.clientEmail.lowercased().contains(q)
            }
        }
        if statusFilter != "all" {
            list = list.filter { $0.status == statusFilter }
        }
        return list
    }

    var body: some View {
        VStack(spacing: 0) {
            ListHeaderToolbar(
                title: loc.t("Hóa đơn"),
                count: filtered.count,
                primaryButtonTitle: loc.t("Tạo mới"),
                action: { showingNewInvoice = true },
                searchText: $searchText
            )

            // Filter chips
            filterChips

            // Table
            InvoiceTableView(invoices: filtered, selectedInvoice: $selectedInvoice)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.clear)
        .sheet(isPresented: $showingNewInvoice) {
            NewInvoiceSheet()
                .environmentObject(APIService.shared)
        }
        .sheet(item: $selectedInvoice) { inv in
            InvoiceDetailView(invoice: inv)
                .environmentObject(APIService.shared)
        }
        .onReceive(NotificationCenter.default.publisher(for: .newInvoiceRequested)) { _ in
            showingNewInvoice = true
        }
    }

    @ViewBuilder
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(statusOptions, id: \.0) { (val, label) in
                    let active = statusFilter == val
                    Button { withAnimation(.spring(response: 0.2)) { statusFilter = val } } label: {
                        Text(loc.t(label))
                            .font(.system(size: 12, weight: active ? .semibold : .medium))
                            .foregroundColor(active ? .white : .appText2)
                            .padding(.horizontal, 12).padding(.vertical, 5)
                            .background(
                                Group {
                                    if active {
                                        LinearGradient(colors: [.appIndigo, .appViolet],
                                                       startPoint: .leading, endPoint: .trailing)
                                    } else {
                                        Color.clear
                                    }
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 7))
                            )
                            .background(
                                Group {
                                    if !active {
                                        ZStack {
                                            VisualEffectBlur(material: .hudWindow, blendingMode: .withinWindow)
                                            Color.white.opacity(0.04)
                                        }
                                        .clipShape(RoundedRectangle(cornerRadius: 7))
                                    }
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                            .overlay(RoundedRectangle(cornerRadius: 7)
                                .strokeBorder(active ? Color.white.opacity(0.2) : Color.white.opacity(0.08), lineWidth: 1))
                            .shadow(color: active ? Color.appIndigo.opacity(0.35) : .clear, radius: 6, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20).padding(.vertical, 10)
        }
        GlassDivider()
    }
}
