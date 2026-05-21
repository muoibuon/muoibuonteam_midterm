import SwiftUI

struct PreferencesWindow: View {
    @EnvironmentObject var loc: LocalizationManager
    var body: some View {
        TabView {
            SettingsView()
                .tabItem {
                    Label(loc.t("Cài đặt"), systemImage: "gear")
                }
        }
        .padding()
    }
}
