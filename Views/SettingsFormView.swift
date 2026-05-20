import SwiftUI

struct SettingsFormView: View {
    @Binding var vatRate:      Double
    @Binding var discountRate: Double
    @Binding var autoSync:     Bool

    @AppStorage(AppConstants.Currencies.bankIdKey)      var bankId      = AppConstants.Currencies.defaultBankId
    @AppStorage(AppConstants.Currencies.accountNoKey)   var accountNo   = ""
    @AppStorage(AppConstants.Currencies.accountNameKey) var accountName = ""

    @AppStorage("appearanceMode") private var appearanceMode = "dark"
    @EnvironmentObject var api: APIService
    @EnvironmentObject var loc: LocalizationManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Appearance section
                settingsSection(title: loc.t("GIAO DIỆN")) {
                    settingsRow(loc.t("Chế độ hiển thị")) {
                        HStack(spacing: 8) {
                            ForEach([("dark","Tối"),("light","Sáng"),("system","Hệ thống")], id: \.0) { val, lbl in
                                let active = appearanceMode == val
                                Button {
                                    appearanceMode = val
                                    switch val {
                                    case "light": NSApp.appearance = NSAppearance(named: .aqua)
                                    case "dark":  NSApp.appearance = NSAppearance(named: .darkAqua)
                                    default:      NSApp.appearance = nil
                                    }
                                } label: {
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

                // Language section
                settingsSection(title: loc.t("NGÔN NGỮ")) {
                    settingsRow(loc.t("Ngôn ngữ")) {
                        HStack(spacing: 8) {
                            ForEach([("vi","Tiếng Việt"),("en","Tiếng Anh")], id: \.0) { val, lbl in
                                let active = loc.language == val
                                Button {
                                    loc.language = val
                                } label: {
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

                // Finance section
                settingsSection(title: loc.t("TÀI CHÍNH")) {
                    settingsRow(loc.t("VAT mặc định")) {
                        HStack(spacing: 8) {
                            ForEach([(0.0,"0%"),(0.05,"5%"),(0.08,"8%"),(0.10,"10%")], id: \.0) { val, lbl in
                                let active = abs(vatRate - val) < 0.001
                                Button { vatRate = val } label: {
                                    Text(lbl)
                                        .font(.system(size: 12, weight: active ? .semibold : .medium))
                                        .foregroundColor(active ? .white : .appText2)
                                        .padding(.horizontal, 14).padding(.vertical, 7)
                                        .background(active ? Color.appIndigo : Color.appBg3)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                }.buttonStyle(.plain)
                            }
                        }
                    }

                    settingsRow(loc.t("Chiết khấu mặc định")) {
                        HStack(spacing: 10) {
                            Slider(value: $discountRate, in: 0...50, step: 0.5).tint(.appIndigo)
                            Text(String(format: "%.1f%%", discountRate))
                                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                .foregroundColor(.appText1).frame(width: 44)
                        }
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(Color.appBg2).clipShape(RoundedRectangle(cornerRadius: 7))
                        .overlay(RoundedRectangle(cornerRadius: 7).strokeBorder(Color.appBorder, lineWidth: 1))
                        .frame(width: 250)
                    }
                }

                // Bank / VietQR section
                settingsSection(title: loc.t("NGÂN HÀNG & VIETQR")) {
                    settingsRow(loc.t("Ngân hàng")) {
                        Picker("", selection: $bankId) {
                            ForEach(AppConstants.Banks.all) { bank in
                                Text("\(bank.shortName) — \(bank.name)").tag(bank.id)
                            }
                        }
                        .pickerStyle(.menu).tint(.appIndigo)
                        .padding(.horizontal, 10).padding(.vertical, 7)
                        .background(Color.appBg2).clipShape(RoundedRectangle(cornerRadius: 7))
                        .overlay(RoundedRectangle(cornerRadius: 7).strokeBorder(Color.appBorder, lineWidth: 1))
                        .frame(width: 260)
                    }

                    settingsRow(loc.t("Số tài khoản")) {
                        TextField("0123456789", text: $accountNo)
                            .textFieldStyle(DarkTextFieldStyle()).frame(width: 200)
                    }

                    settingsRow(loc.t("Tên tài khoản")) {
                        TextField("NGUYEN VAN A", text: $accountName)
                            .textFieldStyle(DarkTextFieldStyle()).frame(width: 260)
                    }

                    // Live QR preview
                    if !accountNo.isEmpty {
                        let qrURL = APIService.shared.vietQRURL(
                            bankId: bankId, accountNo: accountNo,
                            amount: 100000, info: "Xem truoc QR",
                            accountName: accountName.isEmpty ? "PREVIEW" : accountName
                        )
                        HStack(spacing: 16) {
                            if let url = qrURL {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let img):
                                        img.resizable().aspectRatio(contentMode: .fit)
                                            .frame(width: 110, height: 110)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    case .empty: ProgressView().frame(width: 110, height: 110)
                                    default:
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.appBg3).frame(width: 110, height: 110)
                                    }
                                }
                            }
                            VStack(alignment: .leading, spacing: 6) {
                                Text(loc.t("Xem trước QR"))
                                    .font(.system(size: 12, weight: .semibold)).foregroundColor(.appText1)
                                Text("\(AppConstants.Banks.all.first { $0.id == bankId }?.name ?? bankId)")
                                    .font(.system(size: 11)).foregroundColor(.appText2)
                                Text(accountNo)
                                    .font(.system(size: 11, design: .monospaced)).foregroundColor(.appIndigo)
                                if !accountName.isEmpty {
                                    Text(accountName)
                                        .font(.system(size: 10)).foregroundColor(.appText3)
                                }
                            }
                        }
                        .padding(14).background(Color.appBg2)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.appBorder, lineWidth: 1))
                    }
                }

                // Sync section
                settingsSection(title: loc.t("ĐỒNG BỘ")) {
                    settingsRow(loc.t("Đồng bộ tự động")) {
                        Toggle("", isOn: $autoSync).tint(.appIndigo).labelsHidden()
                    }
                    if let lastUpdate = api.lastRatesUpdate {
                        settingsRow(loc.t("Tỷ giá cập nhật")) {
                            HStack(spacing: 10) {
                                Text(lastUpdate.formattedString(pattern: "HH:mm · dd/MM/yyyy"))
                                    .font(.system(size: 12)).foregroundColor(.appText2)
                                Button {
                                    Task { await api.fetchExchangeRates() }
                                } label: {
                                    HStack(spacing: 5) {
                                        Image(systemName: "arrow.clockwise")
                                            .font(.system(size: 11))
                                        Text(loc.t("Làm mới"))
                                            .font(.system(size: 12, weight: .medium))
                                    }
                                    .foregroundColor(.appIndigo)
                                }.buttonStyle(.plain)
                            }
                        }
                    }
                }

                Spacer()
            }
            .padding(24)
        }
        .background(Color.clear)
        .scrollContentBackground(.hidden)
    }

    @ViewBuilder
    private func settingsSection<C: View>(title: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 10, weight: .semibold)).tracking(1)
                .foregroundColor(.appText3)
                .padding(.horizontal, 16).padding(.top, 14).padding(.bottom, 10)
            GlassDivider()
            content()
        }
        .glassCard(radius: 14)
    }

    @ViewBuilder
    private func settingsRow<C: View>(_ label: String, @ViewBuilder content: () -> C) -> some View {
        HStack {
            Text(label).font(.system(size: 13)).foregroundColor(.appText2)
            Spacer()
            content()
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        Rectangle().fill(Color.appBorder).frame(height: 1).padding(.horizontal, 16)
    }
}
