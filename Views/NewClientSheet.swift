import SwiftUI

struct NewClientSheet: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var api: APIService
    @EnvironmentObject var loc: LocalizationManager

    // Form state
    @State private var name           = ""
    @State private var companyName    = ""
    @State private var companyType    = "tnhh"
    @State private var email          = ""
    @State private var phone          = ""
    @State private var taxCode        = ""
    @State private var address        = ""
    @State private var city           = ""
    @State private var country        = "Việt Nam"
    @State private var website        = ""
    @State private var industry       = ""
    @State private var creditLimit    = ""
    @State private var paymentTerm    = 30
    @State private var status         = "active"
    @State private var notes          = ""
    @State private var countrySearch  = ""
    @State private var showCountryList = false
    @State private var showError      = false
    @State private var errorMsg       = ""

    private var companyTypes: [(String, String)] {
        [
            ("tnhh", loc.t("TNHH")), ("cp", loc.t("Cổ phần")), ("tu_nhan", loc.t("Tư nhân")),
            ("hop_danh", loc.t("Hợp danh")), ("khac", loc.t("Khác"))
        ]
    }
    private let paymentTerms = [7, 14, 30, 45, 60, 90]

    private var filteredCountries: [String] {
        countrySearch.isEmpty
            ? api.countries
            : api.countries.filter { $0.localizedCaseInsensitiveContains(countrySearch) }
    }

    var body: some View {
        ZStack {
            VisualEffectBlur(material: .hudWindow, blendingMode: .withinWindow)
                .ignoresSafeArea()
            Color.appBg.opacity(0.72)
                .ignoresSafeArea()
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(loc.t("Thêm Khách Hàng Mới"))
                            .font(.system(size: 16, weight: .bold)).foregroundColor(.appText1)
                        Text(loc.t("Thông tin doanh nghiệp"))
                            .font(.system(size: 12)).foregroundColor(.appText3)
                    }
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").font(.system(size: 13, weight: .medium))
                            .foregroundColor(.appText3)
                            .frame(width: 28, height: 28).background(Color.appBg2).clipShape(Circle())
                    }.buttonStyle(.plain)
                }
                .padding(.horizontal, 24).padding(.vertical, 16)

                Rectangle().fill(Color.appBorder).frame(height: 1)

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        companySection
                        contactSection
                        addressSection
                        businessSection
                        notesSection
                    }
                    .padding(24)
                }

                Rectangle().fill(Color.appBorder).frame(height: 1)

                HStack {
                    Spacer()
                    Button(loc.t("Hủy")) { dismiss() }.buttonStyle(GhostButtonStyle())
                    Button(loc.t("Lưu khách hàng")) { save() }.buttonStyle(PrimaryButtonStyle())
                }
                .padding(.horizontal, 24).padding(.vertical, 14)
            }
        }
        .frame(width: 680, height: 560)
        .task { await api.fetchCountries() }
        .alert(loc.t("Lỗi"), isPresented: $showError) {
            Button("OK") {}
        } message: { Text(errorMsg) }
    }

    // ── Sections ─────────────────────────────────────────
    private var companySection: some View {
        SheetSection(title: loc.t("THÔNG TIN DOANH NGHIỆP")) {
            HStack(spacing: 12) {
                SheetField(label: loc.t("Tên công ty")) {
                    TextField("Công ty TNHH ABC", text: $companyName)
                        .textFieldStyle(DarkTextFieldStyle())
                }
                SheetField(label: loc.t("Loại hình")) {
                    Picker("", selection: $companyType) {
                        ForEach(companyTypes, id: \.0) { Text($1).tag($0) }
                    }
                    .pickerStyle(.menu).tint(.appIndigo)
                    .padding(.horizontal, 10).padding(.vertical, 7)
                    .background(Color.appBg2).clipShape(RoundedRectangle(cornerRadius: 7))
                    .overlay(RoundedRectangle(cornerRadius: 7).strokeBorder(Color.appBorder, lineWidth: 1))
                }
            }
            HStack(spacing: 12) {
                SheetField(label: loc.t("Tên liên hệ")) {
                    TextField("Nguyễn Văn A", text: $name)
                        .textFieldStyle(DarkTextFieldStyle())
                }
                SheetField(label: loc.t("Mã số thuế")) {
                    TextField("0123456789", text: $taxCode)
                        .textFieldStyle(DarkTextFieldStyle())
                }
            }
        }
    }

    private var contactSection: some View {
        SheetSection(title: loc.t("LIÊN HỆ")) {
            HStack(spacing: 12) {
                SheetField(label: "Email") {
                    TextField("contact@company.com", text: $email)
                        .textFieldStyle(DarkTextFieldStyle())
                }
                SheetField(label: loc.t("Điện thoại")) {
                    TextField("0912 345 678", text: $phone)
                        .textFieldStyle(DarkTextFieldStyle())
                }
            }
            HStack(spacing: 12) {
                SheetField(label: "Website") {
                    TextField("www.company.com", text: $website)
                        .textFieldStyle(DarkTextFieldStyle())
                }
                SheetField(label: loc.t("Ngành nghề")) {
                    TextField(loc.t("Công nghệ thông tin"), text: $industry)
                        .textFieldStyle(DarkTextFieldStyle())
                }
            }
        }
    }

    private var addressSection: some View {
        SheetSection(title: loc.t("ĐỊA CHỈ")) {
            SheetField(label: loc.t("Địa chỉ")) {
                TextField(loc.t("Số nhà, đường, phường/xã"), text: $address)
                    .textFieldStyle(DarkTextFieldStyle())
            }
            HStack(spacing: 12) {
                SheetField(label: loc.t("Thành phố")) {
                    TextField("Hà Nội", text: $city)
                        .textFieldStyle(DarkTextFieldStyle())
                }
                SheetField(label: loc.t("Quốc gia")) {
                    countryPicker
                }
            }
        }
    }

    private var businessSection: some View {
        SheetSection(title: loc.t("THƯƠNG MẠI")) {
            HStack(spacing: 12) {
                SheetField(label: loc.t("Hạn mức tín dụng (VND)")) {
                    TextField("50,000,000", text: $creditLimit)
                        .textFieldStyle(DarkTextFieldStyle())
                }
                SheetField(label: loc.t("Kỳ thanh toán")) {
                    Picker("", selection: $paymentTerm) {
                        ForEach(paymentTerms, id: \.self) { Text("\($0) \(loc.t("ngày"))").tag($0) }
                    }
                    .pickerStyle(.menu).tint(.appIndigo)
                    .padding(.horizontal, 10).padding(.vertical, 7)
                    .background(Color.appBg2).clipShape(RoundedRectangle(cornerRadius: 7))
                    .overlay(RoundedRectangle(cornerRadius: 7).strokeBorder(Color.appBorder, lineWidth: 1))
                }
            }
            SheetField(label: loc.t("Trạng thái")) {
                HStack(spacing: 8) {
                    ForEach([("active","Hoạt động"),("inactive","Tạm dừng")], id: \.0) { val, lbl in
                        let active = status == val
                        Button { status = val } label: {
                            Text(loc.t(lbl))
                                .font(.system(size: 12, weight: active ? .semibold : .medium))
                                .foregroundColor(active ? .white : .appText2)
                                .padding(.horizontal, 14).padding(.vertical, 7)
                                .background(active ? Color.appIndigo : Color.appBg3)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }.buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var notesSection: some View {
        SheetSection(title: loc.t("GHI CHÚ")) {
            TextEditor(text: $notes)
                .scrollContentBackground(.hidden)
                .font(.system(size: 13)).foregroundColor(.appText2)
                .padding(10).background(Color.appBg2)
                .clipShape(RoundedRectangle(cornerRadius: 7))
                .overlay(RoundedRectangle(cornerRadius: 7).strokeBorder(Color.appBorder, lineWidth: 1))
                .frame(height: 60)
        }
    }

    @ViewBuilder
    private var countryPicker: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                showCountryList.toggle()
                if showCountryList && api.countries.isEmpty {
                    Task { await api.fetchCountries() }
                }
            } label: {
                HStack {
                    Text(country).font(.system(size: 13)).foregroundColor(.appText1)
                    Spacer()
                    Image(systemName: showCountryList ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10)).foregroundColor(.appText3)
                }
                .padding(.horizontal, 10).padding(.vertical, 8)
                .background(Color.appBg2)
                .clipShape(RoundedRectangle(cornerRadius: 7))
                .overlay(RoundedRectangle(cornerRadius: 7).strokeBorder(Color.appBorder, lineWidth: 1))
            }
            .buttonStyle(.plain)

            if showCountryList {
                VStack(spacing: 0) {
                    HStack(spacing: 6) {
                        Image(systemName: "magnifyingglass").font(.system(size: 11)).foregroundColor(.appText3)
                        TextField(loc.t("Tìm quốc gia..."), text: $countrySearch)
                            .textFieldStyle(.plain).font(.system(size: 12)).foregroundColor(.appText1)
                    }
                    .padding(.horizontal, 10).padding(.vertical, 7)
                    .background(Color.appBg3)

                    Rectangle().fill(Color.appBorder).frame(height: 1)

                    if api.isLoadingCountries {
                        ProgressView().padding(12)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(filteredCountries.prefix(40), id: \.self) { c in
                                    Button { country = c; showCountryList = false; countrySearch = "" } label: {
                                        HStack {
                                            Text(c).font(.system(size: 12)).foregroundColor(.appText2)
                                            Spacer()
                                            if country == c {
                                                Image(systemName: "checkmark").font(.system(size: 10)).foregroundColor(.appIndigo)
                                            }
                                        }
                                        .padding(.horizontal, 12).padding(.vertical, 7)
                                    }
                                    .buttonStyle(.plain)
                                    Rectangle().fill(Color.appBorder).frame(height: 1)
                                }
                            }
                        }
                        .frame(maxHeight: 160)
                    }
                }
                .background(Color.appBg1)
                .clipShape(RoundedRectangle(cornerRadius: 7))
                .overlay(RoundedRectangle(cornerRadius: 7).strokeBorder(Color.appBorder, lineWidth: 1))
            }
        }
    }

    // ── Save ─────────────────────────────────────────────
    private func save() {
        let displayName = companyName.isEmpty ? name : companyName
        guard !displayName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMsg = loc.t("Vui lòng nhập tên công ty hoặc tên liên hệ")
            showError = true; return
        }
        guard !email.isEmpty || !phone.isEmpty else {
            errorMsg = loc.t("Vui lòng nhập ít nhất email hoặc số điện thoại")
            showError = true; return
        }

        guard let client = CoreDataManager.shared.createObject(Client.self) else { return }
        client.id          = UUID()
        client.name        = name.isEmpty ? companyName : name
        client.companyName = companyName
        client.companyType = companyType
        client.email       = email
        client.phone       = phone
        client.taxCode     = taxCode
        client.address     = address
        client.city        = city
        client.country     = country
        client.website     = website
        client.industry    = industry
        client.creditLimit = Double(creditLimit.replacingOccurrences(of: ",", with: "")) ?? 0
        client.paymentTerm = Int32(paymentTerm)
        client.status      = status
        client.notes       = notes
        client.totalInvoices      = 0
        client.totalRevenue       = 0
        client.outstandingBalance = 0
        client.createdAt   = Date()
        client.updatedAt   = Date()

        CoreDataManager.shared.save()
        dismiss()
    }
}

// MARK: - Local helpers
private struct SheetSection<C: View>: View {
    let title: String
    @ViewBuilder let content: () -> C
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 10, weight: .semibold)).tracking(1)
                .foregroundColor(.appText3)
            content()
        }
    }
}

private struct SheetField<C: View>: View {
    let label: String
    @ViewBuilder let content: () -> C
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label).font(.system(size: 11, weight: .medium)).foregroundColor(.appText2)
            content()
        }
        .frame(maxWidth: .infinity)
    }
}
