import SwiftUI
import AppKit

struct MainWindow: View {
    @State private var selectedTab: String = "invoices"
    @AppStorage("appearanceMode") private var appearanceMode = "dark"

    private var preferredScheme: ColorScheme? {
        switch appearanceMode {
        case "light": return .light
        case "dark":  return .dark
        default:      return nil
        }
    }

    var body: some View {
        ZStack {
            // True Liquid Glass — blur through to desktop
            VisualEffectBlur(material: .windowBackground, blendingMode: .behindWindow)
                .ignoresSafeArea()

            Color.appBg.opacity(0.72)
                .ignoresSafeArea()

            Group {
                HStack(spacing: 0) {
                    MainSidebar(selectedTab: $selectedTab)
                        .frame(width: 216)

                    // Glass divider
                    GlassDivider()
                        .frame(width: 1)
                        .frame(maxHeight: .infinity)

                    ZStack {
                        switch selectedTab {
                        case "dashboard": DashboardView()
                        case "invoices":  InvoiceListView()
                        case "clients":   ClientsListView()
                        case "settings":  SettingsView()
                        default:          EmptyView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .id(appearanceMode)
        }
        .frame(minWidth: 960, minHeight: 620)
        .preferredColorScheme(preferredScheme)
        .onAppear {
            configureWindow()
            applyNSAppearance(appearanceMode)
        }
        .onChange(of: appearanceMode) { newMode in
            applyNSAppearance(newMode)
        }
    }

    private func configureWindow() {
        guard let window = NSApp.windows.first else { return }
        window.isOpaque = false
        window.backgroundColor = .clear
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.styleMask.insert(.fullSizeContentView)
    }

    private func applyNSAppearance(_ mode: String) {
        switch mode {
        case "light": NSApp.appearance = NSAppearance(named: .aqua)
        case "dark":  NSApp.appearance = NSAppearance(named: .darkAqua)
        default:      NSApp.appearance = nil
        }
    }
}
