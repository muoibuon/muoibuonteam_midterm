import SwiftUI

struct SettingsView: View {
    @AppStorage("defaultVATRate")      private var vatRate      = 0.1
    @AppStorage("defaultDiscountRate") private var discountRate = 0.0
    @AppStorage("autoSync")            private var autoSync     = true
    @EnvironmentObject var loc: LocalizationManager

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(loc.t("Tùy chọn"))
                        .font(.system(size: 22, weight: .bold)).foregroundColor(.appText1)
                    Text(loc.t("Cài đặt ứng dụng và tích hợp"))
                        .font(.system(size: 13)).foregroundColor(.appText3)
                }
                Spacer()
            }
            .padding(.horizontal, 24).padding(.vertical, 20)

            GlassDivider()

            SettingsFormView(vatRate: $vatRate, discountRate: $discountRate, autoSync: $autoSync)
                .environmentObject(APIService.shared)
        }
        .background(Color.clear)
    }
}
