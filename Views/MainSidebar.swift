import SwiftUI

struct MainSidebar: View {
    @Binding var selectedTab: String
    @EnvironmentObject var api: APIService
    @EnvironmentObject var loc: LocalizationManager

    var body: some View {
        ZStack {
            // Sidebar glass — macOS .sidebar material with behind-window blending
            VisualEffectBlur(material: .sidebar, blendingMode: .behindWindow)
            Color.appBg1.opacity(0.55)

            VStack(alignment: .leading, spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 2) {
                        sectionLabel(loc.t("Chính"))
                        navItem("dashboard", icon: "chart.bar.fill",   label: "Dashboard")
                        navItem("invoices",  icon: "doc.text.fill",    label: loc.t("Hóa đơn"))
                        navItem("clients",   icon: "person.2.fill",    label: loc.t("Khách hàng"))

                        Spacer().frame(height: 12)
                        sectionLabel(loc.t("Hệ thống"))
                        navItem("settings",  icon: "gearshape.fill",   label: loc.t("Tùy chọn"))
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 16)
                }

                Spacer()

                // Sync status footer
                VStack(alignment: .leading, spacing: 4) {
                    GlassDivider()
                    HStack(spacing: 8) {
                        Circle()
                            .fill(api.isLoadingRates ? Color.appOrange : Color.appGreen)
                            .frame(width: 6, height: 6)
                            .shadow(color: (api.isLoadingRates ? Color.appOrange : Color.appGreen).opacity(0.6),
                                    radius: 4, x: 0, y: 0)
                        Text(api.isLoadingRates ? loc.t("Đang tải tỷ giá...") :
                             (api.rates.isEmpty ? loc.t("Chưa có tỷ giá") : loc.t("Tỷ giá cập nhật")))
                            .font(.system(size: 11))
                            .foregroundColor(.appText3)
                        Spacer()
                        if !api.rates.isEmpty {
                            Button {
                                Task { await APIService.shared.fetchExchangeRates() }
                            } label: {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 10))
                                    .foregroundColor(.appText3)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
            }
        }
    }

    @ViewBuilder
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(.appText3)
            .tracking(1.2)
            .textCase(.uppercase)
            .padding(.leading, 12)
            .padding(.top, 10)
            .padding(.bottom, 4)
    }

    @ViewBuilder
    private func navItem(_ tab: String, icon: String, label: String) -> some View {
        let active = selectedTab == tab
        Button { withAnimation(.spring(response: 0.25)) { selectedTab = tab } } label: {
            HStack(spacing: 10) {
                ZStack {
                    if active {
                        RoundedRectangle(cornerRadius: 7)
                            .fill(Color.appIndigo.opacity(0.25))
                            .frame(width: 26, height: 26)
                    }
                    Image(systemName: icon)
                        .font(.system(size: 13))
                        .foregroundColor(active ? .appIndigo : .appText3)
                        .frame(width: 18)
                }
                Text(label)
                    .font(.system(size: 13, weight: active ? .semibold : .medium))
                    .foregroundColor(active ? .appText1 : .appText2)
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                Group {
                    if active {
                        ZStack {
                            VisualEffectBlur(material: .hudWindow, blendingMode: .withinWindow)
                            Color.appIndigo.opacity(0.12)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 9))
                    } else {
                        Color.clear
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 9)
                    .strokeBorder(active ? Color.appIndigo.opacity(0.35) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
