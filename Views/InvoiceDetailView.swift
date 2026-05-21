import SwiftUI

struct InvoiceDetailView: View {
    @ObservedObject var invoice: Invoice
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var api: APIService
    @EnvironmentObject var loc: LocalizationManager

    @AppStorage(AppConstants.Currencies.bankIdKey)      var bankId = AppConstants.Currencies.defaultBankId
    @AppStorage(AppConstants.Currencies.accountNoKey)   var accountNo = ""
    @AppStorage(AppConstants.Currencies.accountNameKey) var accountName = ""

    @State private var showDeleteConfirm = false

    var body: some View {
        ZStack {
            VisualEffectBlur(material: .hudWindow, blendingMode: .withinWindow)
                .ignoresSafeArea()
            Color.appBg.opacity(0.7)
                .ignoresSafeArea()
            VStack(spacing: 0) {
                detailHeader
                GlassDivider()

                ScrollView {
                    HStack(alignment: .top, spacing: 16) {
                        // Left column
                        VStack(spacing: 14) {
                            invoiceInfoCard
                            clientCard
                            notesCard
                        }
                        .frame(maxWidth: .infinity)

                        // Right column
                        VStack(spacing: 14) {
                            financialCard
                            paymentActionsCard
                            if !accountNo.isEmpty {
                                vietQRCard
                            }
                        }
                        .frame(width: 280)
                    }
                    .padding(20)
                }
            }
        }
        .frame(width: 760, height: 580)
        .alert(loc.t("Xóa hóa đơn?"), isPresented: $showDeleteConfirm) {
            Button(loc.t("Xóa"), role: .destructive) { deleteInvoice() }
            Button(loc.t("Hủy"), role: .cancel) {}
        } message: {
            Text(loc.t("Thao tác này không thể hoàn tác."))
        }
    }

    // ── Header ──────────────────────────────────────────
    private var detailHeader: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 10) {
                    Text(invoice.invoiceNumber)
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.appText1)
                    StatusBadge(status: invoice.status)
                    if invoice.isOverdue {
                        Text(loc.t("QUÁ HẠN"))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 7).padding(.vertical, 2)
                            .background(Color.appRed)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
                Text("\(loc.t("Phát hành")) \(invoice.invoiceDate.formattedString()) · \(loc.t("Đến hạn")) \(invoice.dueDate.formattedString())")
                    .font(.system(size: 11))
                    .foregroundColor(.appText3)
            }
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark").font(.system(size: 13, weight: .medium))
                    .foregroundColor(.appText3)
                    .frame(width: 28, height: 28).background(Color.appBg2).clipShape(Circle())
            }.buttonStyle(.plain)
        }
        .padding(.horizontal, 20).padding(.vertical, 16)
    }

    // ── Invoice info ─────────────────────────────────────
    private var invoiceInfoCard: some View {
        DetailCard(title: loc.t("THÔNG TIN HÓA ĐƠN")) {
            infoRow(loc.t("Mô tả"),  invoice.description_field.isEmpty ? "—" : invoice.description_field)
            infoRow(loc.t("Ngày HĐ"),    invoice.invoiceDate.formattedString())
            infoRow(loc.t("Đến hạn"),    invoice.dueDate.formattedString())
            infoRow(loc.t("PT thanh toán"), paymentMethodLabel(invoice.paymentMethod))
        }
    }

    // ── Client info ──────────────────────────────────────
    private var clientCard: some View {
        DetailCard(title: loc.t("KHÁCH HÀNG")) {
            infoRow(loc.t("Tên"),   invoice.clientName.isEmpty ? "—" : invoice.clientName)
            infoRow("Email", invoice.clientEmail.isEmpty ? "—" : invoice.clientEmail)
            infoRow(loc.t("ĐT"),    invoice.clientPhone.isEmpty ? "—" : invoice.clientPhone)
            infoRow(loc.t("ĐC"),    invoice.clientAddress.isEmpty ? "—" : invoice.clientAddress)
        }
    }

    // ── Notes ────────────────────────────────────────────
    private var notesCard: some View {
        DetailCard(title: loc.t("GHI CHÚ")) {
            Text(invoice.notes.isEmpty ? loc.t("Không có ghi chú") : invoice.notes)
                .font(.system(size: 12))
                .foregroundColor(invoice.notes.isEmpty ? .appText3 : .appText2)
                .padding(.horizontal, 14).padding(.vertical, 10)
        }
    }

    // ── Financial breakdown ──────────────────────────────
    private var financialCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(loc.t("TÀI CHÍNH"))
                .font(.system(size: 10, weight: .semibold)).tracking(1)
                .foregroundColor(.appText3)
                .padding(.horizontal, 14).padding(.top, 14).padding(.bottom, 10)

            GlassDivider()

            finRow(loc.t("Tạm tính"),   fmtVND(invoice.subtotal))
            if invoice.discountAmount > 0 {
                finRow("\(loc.t("Chiết khấu")) \(Int(invoice.discountRate * 100))%",
                       "— \(fmtVND(invoice.discountAmount))", color: .appRed)
                finRow(loc.t("Sau CK"), fmtVND(invoice.subtotalAfterDiscount))
            }
            if invoice.vatAmount > 0 {
                finRow("VAT \(Int(invoice.vatRate * 100))%",
                       "+ \(fmtVND(invoice.vatAmount))", color: .appOrange)
            }

            GlassDivider()

            HStack {
                Text(loc.t("TỔNG CỘNG")).font(.system(size: 11, weight: .bold)).foregroundColor(.appText2)
                Spacer()
                Text(fmtVND(invoice.totalAmount))
                    .font(.system(size: 17, weight: .bold)).foregroundColor(.appGreen)
            }
            .padding(.horizontal, 14).padding(.vertical, 12)

            if invoice.paidAmount > 0 {
                GlassDivider()
                finRow(loc.t("Đã thanh toán"), fmtVND(invoice.paidAmount), color: .appGreen)
                finRow(loc.t("Còn lại"),       fmtVND(invoice.remainingAmount),
                       color: invoice.remainingAmount > 0 ? .appOrange : .appGreen)
            }

            // Progress bar
            if invoice.totalAmount > 0 {
                let pct = min(invoice.paidAmount / invoice.totalAmount, 1.0)
                VStack(spacing: 4) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3).fill(Color.appBg3).frame(height: 5)
                            RoundedRectangle(cornerRadius: 3).fill(Color.appGreen)
                                .frame(width: geo.size.width * pct, height: 5)
                        }
                    }
                    .frame(height: 5)
                }
                .padding(.horizontal, 14).padding(.bottom, 14)
            }
        }
        .cardStyle()
    }

    // ── Payment actions ──────────────────────────────────
    private var paymentActionsCard: some View {
        VStack(spacing: 8) {
            if invoice.status != "paid" && invoice.status != "cancelled" {
                Button {
                    invoice.paymentStatus = "paid"
                    invoice.paidAmount    = invoice.totalAmount
                    invoice.status        = "paid"
                    invoice.updatedAt     = Date()
                    CoreDataManager.shared.save()
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text(loc.t("Đánh dấu Đã thanh toán"))
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .background(Color.appGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }

            if invoice.status == "pending" || invoice.status == "draft" {
                Button {
                    invoice.status    = "cancelled"
                    invoice.updatedAt = Date()
                    CoreDataManager.shared.save()
                } label: {
                    HStack {
                        Image(systemName: "xmark.circle")
                        Text(loc.t("Hủy hóa đơn"))
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.appRed)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .background(Color.appRed.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.appRed.opacity(0.3), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }

            Button { showDeleteConfirm = true } label: {
                HStack {
                    Image(systemName: "trash")
                    Text(loc.t("Xóa hóa đơn"))
                }
                .font(.system(size: 12))
                .foregroundColor(.appText3)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .cardStyle()
    }

    // ── VietQR ───────────────────────────────────────────
    private var vietQRCard: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "qrcode").foregroundColor(.appIndigo)
                Text(loc.t("QR Chuyển khoản"))
                    .font(.system(size: 12, weight: .semibold)).foregroundColor(.appText1)
                Spacer()
            }
            .padding(.horizontal, 14).padding(.top, 12)

            let url = api.vietQRURL(
                bankId: bankId,
                accountNo: accountNo,
                amount: invoice.remainingAmount > 0 ? invoice.remainingAmount : invoice.totalAmount,
                info: invoice.invoiceNumber,
                accountName: accountName
            )

            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .padding(.horizontal, 14)
                    case .failure:
                        Text(loc.t("Không tải được QR")).font(.system(size: 11))
                            .foregroundColor(.appText3).padding()
                    case .empty:
                        ProgressView().padding()
                    @unknown default: EmptyView()
                    }
                }

                Text("\(bankId) · \(accountNo)")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.appText3)
                    .padding(.horizontal, 14).padding(.bottom, 12)
            }
        }
        .cardStyle()
    }

    // ── Helpers ──────────────────────────────────────────
    @ViewBuilder
    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(label).font(.system(size: 11)).foregroundColor(.appText3).frame(width: 90, alignment: .leading)
            Text(value).font(.system(size: 12)).foregroundColor(.appText2).frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 14).padding(.vertical, 6)
    }

    @ViewBuilder
    private func finRow(_ label: String, _ value: String, color: Color = .appText1) -> some View {
        HStack {
            Text(label).font(.system(size: 11)).foregroundColor(.appText3)
            Spacer()
            Text(value).font(.system(size: 12, weight: .medium)).foregroundColor(color)
        }
        .padding(.horizontal, 14).padding(.vertical, 7)
    }

    private func fmtVND(_ v: Double) -> String {
        let f = NumberFormatter(); f.numberStyle = .decimal; f.maximumFractionDigits = 0
        return "\(f.string(from: NSNumber(value: v)) ?? "0")₫"
    }

    private func paymentMethodLabel(_ m: String) -> String {
        switch m {
        case "bank": return loc.t("Chuyển khoản")
        case "cash": return loc.t("Tiền mặt")
        case "card": return loc.t("Thẻ tín dụng")
        default:     return m
        }
    }

    private func deleteInvoice() {
        CoreDataManager.shared.delete(invoice)
        dismiss()
    }
}

// MARK: - Detail card container
private struct DetailCard<C: View>: View {
    let title: String
    @ViewBuilder let content: () -> C
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 10, weight: .semibold)).tracking(1)
                .foregroundColor(.appText3)
                .padding(.horizontal, 14).padding(.top, 14).padding(.bottom, 10)
            GlassDivider()
            content()
        }
        .cardStyle()
    }
}
