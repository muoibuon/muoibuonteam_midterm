import SwiftUI

struct ClientsListView: View {
    @FetchRequest(
        entity: Client.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Client.companyName, ascending: true)]
    ) var clients: FetchedResults<Client>

    @State private var selectedClient: Client?
    @State private var showingNewClient = false
    @State private var searchText       = ""
    @State private var statusFilter     = "all"
    @EnvironmentObject var loc: LocalizationManager

    private let statusOptions = [
        ("all", "Tất cả"), ("active", "Hoạt động"),
        ("inactive", "Không HĐ"), ("blacklisted", "Cấm")
    ]

    private var filtered: [Client] {
        var list = Array(clients)
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            list = list.filter {
                $0.name.lowercased().contains(q) ||
                $0.companyName.lowercased().contains(q) ||
                $0.email.lowercased().contains(q) ||
                $0.taxCode.lowercased().contains(q)
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
                title: loc.t("Khách hàng"),
                count: filtered.count,
                primaryButtonTitle: loc.t("Tạo mới"),
                action: { showingNewClient = true },
                searchText: $searchText
            )

            // Filter chips
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
                                            ZStack {
                                                VisualEffectBlur(material: .hudWindow, blendingMode: .withinWindow)
                                                Color.white.opacity(0.04)
                                            }
                                        }
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 7))
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

            ClientsTableView(clients: filtered, selectedClient: $selectedClient)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.clear)
        .sheet(isPresented: $showingNewClient) {
            NewClientSheet()
                .environmentObject(APIService.shared)
        }
        .onReceive(NotificationCenter.default.publisher(for: .newClientRequested)) { _ in
            showingNewClient = true
        }
    }
}
