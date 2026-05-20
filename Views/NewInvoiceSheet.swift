import SwiftUI

struct NewInvoiceSheet: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var api: APIService
    @EnvironmentObject var loc: LocalizationManager

    // Fetch existing clients for picker
    @FetchRequest(entity: Client.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Client.companyName, ascending: true)])
    var clients: FetchedResults<Client>

    // Form state
    @State private var invoiceNumber   = ""
    @State private var selectedClient: Client?
    @State private var manualName      = ""
    @State private var manualEmail     = ""
    @State private var invoiceDate     = Date()
    @State private var dueDate         = Date().addingTimeInterval(30 * 86400)
    @State private var description_    = ""
    @State private var subtotalInput   = ""
    @State private var discountRate    = 0.0      // 0–100 %
    @State private var vatRate         = 0.1      // 0.0, 0.05, 0.08, 0.10
    @State private var paymentMethod   = "bank"
    @State private var currency        = "VND"
    @State private var notes           = ""
    @State private var showError       = false
    @State private var errorMsg        = ""

    // Bank settings for VietQR preview
    @AppStorage(AppConstants.Currencies.bankIdKey)      var bankId = AppConstants.Currencies.defaultBankId
    @AppStorage(AppConstants.Currencies.accountNoKey)   var accountNo = ""
    @AppStorage(AppConstants.Currencies.accountNameKey) var accountName = ""

    private var subtotal: Double { Double(subtotalInput.replacingOccurrences(of: ",", with: "")) ?? 0 }
    private var discountAmt: Double { subtotal * (discountRate / 100) }
    private var afterDiscount: Double { subtotal - discountAmt }
    private var vatAmt: Double { afterDiscount * vatRate }
    private var total: Double { afterDiscount + vatAmt }
    private var totalVND: Double {
        currency == "VND" ? total : api.toVND(amount: total, from: currency)
    }

    var body: some View {
        ZStack {
            VisualEffectBlur(material: .hudWindow, blendingMode: .withinWindow)
                .ignoresSafeArea()
            Color.appBg.opacity(0.72)
                .ignoresSafeArea()
            VStack(spacing: 0) {
                sheetHeader
                Rectangle().fill(Color.appBorder).frame(height: 1)

                HStack(alignment: .top, spacing: 0) {
                    // Left: form
                    ScrollView {
                        VStack(alignment: .leading, spacing: 22) {
                            generalSection
                            clientSection
                            financialSection
                            noteSection
                        }
                        .padding(24)
                    }
                    .frame(maxWidth: .infinity)

                    Rectangle().fill(Color.appBorder).frame(width: 1)

                    // Right: live preview + VietQR
                    ScrollView {
                        VStack(spacing: 16) {
                            previewCard
                            if !accountNo.isEmpty {
                                vietQRCard
                            } else {
                                qrPromptCard
                            }
                        }
                        .padding(20)
                    }
                    .frame(width: 280)
                }

                Rectangle().fill(Color.appBorder).frame(height: 1)
                sheetFooter
            }
        }
        .frame(width: 860, height: 620)
        .onAppear { generateInvoiceNumber() }
        .alert(loc.t("Lỗi"), isPresented: $showError) {
            Button("OK") {}
        } message: { Text(errorMsg) }
    }

    // ── Header ──────────────────────────────────────────
    private var sheetHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(loc.t("Tạo Hóa Đơn Mới"))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.appText1)
                Text(loc.t("Điền thông tin và nhấn Lưu"))
                    .font(.system(size: 12))
                    .foregroundColor(.appText3)
            }
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark").font(.system(size: 13, weight: .medium))
                    .foregroundColor(.appText3)
                    .frame(width: 28, height: 28)
                    .background(Color.appBg2)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24).padding(.vertical, 16)
    }

    // ── General section ─────────────────────────────────
    private var generalSection: some View {
        SectionBox(title: loc.t("THÔNG TIN CHUNG")) {
            HStack(spacing: 12) {
                FieldBox(label: loc.t("Số hóa đơn")) {
                    TextField("HD-0001", text: $invoiceNumber)
                        .textFieldStyle(DarkTextFieldStyle())
                }
                FieldBox(label: loc.t("Phương thức thanh toán")) {
                    Picker("", selection: $paymentMethod) {
                        Text(loc.t("Chuyển khoản")).tag("bank")
                        Text(loc.t("Tiền mặt")).tag("cash")
                        Text(loc.t("Thẻ tín dụng")).tag("card")
                    }
                    .pickerStyle(.menu)
                    .tint(.appIndigo)
                    .padding(.horizontal, 10).padding(.vertical, 7)
                    .background(Color.appBg2)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                    .overlay(RoundedRectangle(cornerRadius: 7).strokeBorder(Color.appBorder, lineWidth: 1))
                }
            }
            HStack(spacing: 12) {
                FieldBox(label: loc.t("Ngày phát hành")) {
                    DatePicker("", selection: $invoiceDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                }
                FieldBox(label: loc.t("Ngày đến hạn")) {
                    DatePicker("", selection: $dueDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                }
            }
            FieldBox(label: loc.t("Mô tả công việc")) {
                TextField(loc.t("Mô tả dịch vụ hoặc sản phẩm..."), text: $description_)
                    .textFieldStyle(DarkTextFieldStyle())
            }
        }
    }

    // ── Client section ──────────────────────────────────
    private var clientSection: some View {
        SectionBox(title: loc.t("KHÁCH HÀNG")) {
            if clients.isEmpty {
                HStack(spacing: 12) {
                    FieldBox(label: loc.t("Tên khách hàng")) {
                        TextField("Công ty ABC", text: $manualName)
                            .textFieldStyle(DarkTextFieldStyle())
                    }
                    FieldBox(label: "Email") {
                        TextField("email@company.com", text: $manualEmail)
                            .textFieldStyle(DarkTextFieldStyle())
                    }
                }
            } else {
                FieldBox(label: loc.t("Chọn khách hàng")) {
                    Picker(loc.t("Khách hàng"), selection: $selectedClient) {
                        Text(loc.t("— Nhập thủ công —")).tag(nil as Client?)
                        ForEach(clients) { cl in
                            Text(cl.displayName).tag(cl as Client?)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.appIndigo)
                    .padding(.horizontal, 10).padding(.vertical, 7)
                    .background(Color.appBg2)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                    .overlay(RoundedRectangle(cornerRadius: 7).strokeBorder(Color.appBorder, lineWidth: 1))
                }
                if selectedClient == nil {
                    HStack(spacing: 12) {
                        FieldBox(label: loc.t("Tên")) {
                            TextField(loc.t("Tên công ty hoặc cá nhân"), text: $manualName)
                                .textFieldStyle(DarkTextFieldStyle())
                        }
                        FieldBox(label: "Email") {
                            TextField("email@example.com", text: $manualEmail)
                                .textFieldStyle(DarkTextFieldStyle())
                        }
                    }
                } else if let cl = selectedClient {
                    HStack(spacing: 12) {
                        infoChip(label: "Email", value: cl.email)
                        infoChip(label: loc.t("MST"), value: cl.taxCode)
                    }
                }
            }
        }
    }

    // ── Financial section ───────────────────────────────
    private var financialSection: some View {
        SectionBox(title: loc.t("TÀI CHÍNH")) {
            // Currency + rate
            HStack(spacing: 12) {
                FieldBox(label: loc.t("Tiền tệ")) {
                    Picker("", selection: $currency) {
                        ForEach(AppConstants.Currencies.all, id: \.self) { cur in
                            Text(cur).tag(cur)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.appIndigo)
                    .padding(.horizontal, 10).padding(.vertical, 7)
                    .background(Color.appBg2)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                    .overlay(RoundedRectangle(cornerRadius: 7).strokeBorder(Color.appBorder, lineWidth: 1))
                    .onChange(of: currency) { _ in
                        if api.rates.isEmpty { Task { await api.fetchExchangeRates() } }
                    }
                }
                if currency != "VND" {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(loc.t("Tỷ giá quy đổi"))
                            .font(.system(size: 11))
                            .foregroundColor(.appText3)
                        if api.isLoadingRates {
                            ProgressView().scaleEffect(0.7)
                        } else {
                            Text(api.rateDescription(for: currency).isEmpty
                                 ? loc.t("Chưa có tỷ giá") : api.rateDescription(for: currency))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.appIndigo)
                        }
                    }
                }
            }

            // Amounts
            HStack(spacing: 12) {
                FieldBox(label: "\(loc.t("Tạm tính")) (\(currency))") {
                    TextField("0", text: $subtotalInput)
                        .textFieldStyle(DarkTextFieldStyle())
                }
                FieldBox(label: "\(loc.t("Chiết khấu")) (%)") {
                    HStack(spacing: 8) {
                        Slider(value: $discountRate, in: 0...50, step: 0.5)
                            .tint(.appIndigo)
                        Text(String(format: "%.1f%%", discountRate))
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundColor(.appText1)
                            .frame(width: 44)
                    }
                    .padding(.horizontal, 10).padding(.vertical, 8)
                    .background(Color.appBg2)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                    .overlay(RoundedRectangle(cornerRadius: 7).strokeBorder(Color.appBorder, lineWidth: 1))
                }
            }

            FieldBox(label: loc.t("Thuế VAT")) {
                HStack(spacing: 8) {
                    ForEach([(0.0, "0%"), (0.05, "5%"), (0.08, "8%"), (0.10, "10%")], id: \.0) { val, label in
                        let active = abs(vatRate - val) < 0.001
                        Button { vatRate = val } label: {
                            Text(label)
                                .font(.system(size: 12, weight: active ? .semibold : .medium))
                                .foregroundColor(active ? .white : .appText2)
                                .padding(.horizontal, 14).padding(.vertical, 7)
                                .background(active ? Color.appIndigo : Color.appBg3)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // ── Notes section ───────────────────────────────────
    private var noteSection: some View {
        SectionBox(title: loc.t("GHI CHÚ")) {
            TextEditor(text: $notes)
                .scrollContentBackground(.hidden)
                .font(.system(size: 13))
                .foregroundColor(.appText2)
                .padding(10)
                .background(Color.appBg2)
                .clipShape(RoundedRectangle(cornerRadius: 7))
                .overlay(RoundedRectangle(cornerRadius: 7).strokeBorder(Color.appBorder, lineWidth: 1))
                .frame(height: 72)
        }
    }

    // ── Preview card ─────────────────────────────────────
    private var previewCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(loc.t("XEM TRƯỚC"))
                    .font(.system(size: 10, weight: .semibold)).tracking(1)
                    .foregroundColor(.appText3)
                Spacer()
                Text(invoiceNumber.isEmpty ? "HD-XXXX" : invoiceNumber)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.appIndigo)
            }
            .padding(.horizontal, 14).padding(.vertical, 12)

            Rectangle().fill(Color.appBorder).frame(height: 1)

            VStack(spacing: 0) {
                previewRow(loc.t("Khách hàng"),
                           value: selectedClient?.displayName ?? (manualName.isEmpty ? "—" : manualName),
                           bold: true)
                previewRow(loc.t("Tạm tính"),    value: fmtCur(subtotal))
                if discountRate > 0 {
                    previewRow(loc.t("Chiết khấu"), value: "— \(fmtCur(discountAmt))", color: .appRed)
                    previewRow(loc.t("Sau CK"),     value: fmtCur(afterDiscount))
                }
                if vatRate > 0 {
                    previewRow("VAT \(Int(vatRate*100))%", value: "+ \(fmtCur(vatAmt))", color: .appOrange)
                }
            }

            Rectangle().fill(Color.appBorder).frame(height: 1)

            HStack {
                Text(loc.t("TỔNG CỘNG"))
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.appText2)
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(fmtCur(total))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.appGreen)
                    if currency != "VND" {
                        Text("≈ \(fmtVND(totalVND))")
                            .font(.system(size: 11))
                            .foregroundColor(.appText3)
                    }
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 12)
        }
        .background(Color.appBg1)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.appBorder, lineWidth: 1))
    }

    // ── VietQR card ──────────────────────────────────────
    private var vietQRCard: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "qrcode")
                    .foregroundColor(.appIndigo)
                Text(loc.t("VietQR thanh toán"))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.appText1)
                Spacer()
            }
            .padding(.horizontal, 14).padding(.top, 12)

            let qrURL = api.vietQRURL(
                bankId: bankId, accountNo: accountNo,
                amount: totalVND,
                info: invoiceNumber.isEmpty ? loc.t("Thanh toan hoa don") : invoiceNumber,
                accountName: accountName
            )

            if let url = qrURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    case .failure:
                        errorQR
                    case .empty:
                        ProgressView().frame(height: 120)
                    @unknown default:
                        EmptyView()
                    }
                }
                .padding(.horizontal, 14)

                Text("\(bankId) · \(accountNo)")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.appText3)
                    .padding(.bottom, 12)
            }
        }
        .background(Color.appBg1)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.appBorder, lineWidth: 1))
    }

    private var qrPromptCard: some View {
        HStack(spacing: 10) {
            Image(systemName: "qrcode").foregroundColor(.appText3)
            Text(loc.t("Cài đặt tài khoản ngân hàng trong Tùy chọn để hiển thị QR thanh toán"))
                .font(.system(size: 11))
                .foregroundColor(.appText3)
        }
        .padding(14)
        .background(Color.appBg1)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.appBorder, lineWidth: 1))
    }

    private var errorQR: some View {
        Text(loc.t("Không thể tải QR"))
            .font(.system(size: 11))
            .foregroundColor(.appText3)
            .frame(height: 80)
            .frame(maxWidth: .infinity)
    }

    // ── Footer ───────────────────────────────────────────
    private var sheetFooter: some View {
        HStack {
            Spacer()
            Button(loc.t("Hủy")) { dismiss() }
                .buttonStyle(GhostButtonStyle())
            Button(loc.t("Lưu hóa đơn")) { save() }
                .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.horizontal, 24).padding(.vertical, 14)
    }

    // ── Helpers ──────────────────────────────────────────
    @ViewBuilder
    private func previewRow(_ label: String, value: String, bold: Bool = false, color: Color = .appText1) -> some View {
        HStack {
            Text(label).font(.system(size: 11)).foregroundColor(.appText3)
            Spacer()
            Text(value)
                .font(.system(size: 11, weight: bold ? .semibold : .regular))
                .foregroundColor(color)
                .lineLimit(1)
        }
        .padding(.horizontal, 14).padding(.vertical, 7)
    }

    @ViewBuilder
    private func infoChip(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label).font(.system(size: 10)).foregroundColor(.appText3)
            Text(value.isEmpty ? "—" : value)
                .font(.system(size: 12))
                .foregroundColor(.appText2)
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background(Color.appBg2)
        .clipShape(RoundedRectangle(cornerRadius: 7))
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func fmtCur(_ v: Double) -> String {
        let sym = AppConstants.Currencies.symbols[currency] ?? currency
        let f = NumberFormatter(); f.numberStyle = .decimal; f.maximumFractionDigits = 0
        return "\(sym)\(f.string(from: NSNumber(value: v)) ?? "0")"
    }

    private func fmtVND(_ v: Double) -> String {
        let f = NumberFormatter(); f.numberStyle = .decimal; f.maximumFractionDigits = 0
        return "\(f.string(from: NSNumber(value: v)) ?? "0")₫"
    }

    private func generateInvoiceNumber() {
        let existing = CoreDataManager.shared.fetchRequest(Invoice.self,
            sortDescriptors: [NSSortDescriptor(keyPath: \Invoice.invoiceNumber, ascending: false)])
        let count = existing.count
        // Try to parse the latest number
        if let latest = existing.first {
            let parts = latest.invoiceNumber.components(separatedBy: "-")
            if let last = parts.last, let n = Int(last) {
                invoiceNumber = "HD-\(String(format: "%04d", n + 1))"
                return
            }
        }
        invoiceNumber = "HD-\(String(format: "%04d", count + 1))"
    }

    private func save() {
        let clientName = selectedClient?.displayName ?? manualName
        guard !invoiceNumber.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMsg = loc.t("Vui lòng nhập số hóa đơn"); showError = true; return
        }
        guard !clientName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMsg = loc.t("Vui lòng chọn hoặc nhập tên khách hàng"); showError = true; return
        }
        guard subtotal > 0 else {
            errorMsg = loc.t("Vui lòng nhập tạm tính > 0"); showError = true; return
        }

        guard let invoice = CoreDataManager.shared.createObject(Invoice.self) else { return }
        invoice.id             = UUID()
        invoice.invoiceNumber  = invoiceNumber.trimmingCharacters(in: .whitespaces)
        invoice.invoiceDate    = invoiceDate
        invoice.dueDate        = dueDate
        invoice.status         = "pending"

        invoice.clientId      = selectedClient?.id ?? UUID()
        invoice.clientName    = clientName
        invoice.clientEmail   = selectedClient?.email ?? manualEmail
        invoice.clientPhone   = selectedClient?.phone ?? ""
        invoice.clientAddress = selectedClient?.address ?? ""

        let rawSubtotal = currency == "VND" ? subtotal : api.toVND(amount: subtotal, from: currency)
        invoice.subtotal                = rawSubtotal
        invoice.discountRate            = discountRate / 100
        invoice.discountAmount          = rawSubtotal * (discountRate / 100)
        invoice.subtotalAfterDiscount   = rawSubtotal - invoice.discountAmount
        invoice.vatRate                 = vatRate
        invoice.vatAmount               = invoice.subtotalAfterDiscount * vatRate
        invoice.totalAmount             = invoice.subtotalAfterDiscount + invoice.vatAmount

        invoice.paymentMethod  = paymentMethod
        invoice.paymentStatus  = "unpaid"
        invoice.paidAmount     = 0
        invoice.description_field = description_
        invoice.notes          = notes
        invoice.createdAt      = Date()
        invoice.updatedAt      = Date()

        CoreDataManager.shared.save()
        dismiss()
    }
}

// MARK: - Reusable form components (local to this file)
private struct SectionBox<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 10, weight: .semibold)).tracking(1)
                .foregroundColor(.appText3)
            content()
        }
    }
}

private struct FieldBox<Content: View>: View {
    let label: String
    @ViewBuilder let content: () -> Content
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.appText2)
            content()
        }
        .frame(maxWidth: .infinity)
    }
}
