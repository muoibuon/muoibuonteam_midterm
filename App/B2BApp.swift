import SwiftUI

@main
struct B2BInvoiceApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var localization = LocalizationManager()

    var body: some Scene {
        WindowGroup {
            MainWindow()
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .environmentObject(APIService.shared)
                .environmentObject(localization)
        }
        .defaultSize(width: 1280, height: 800)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About \(AppConstants.appName)") {
                    appDelegate.showAbout()
                }
                .keyboardShortcut("a", modifiers: [.command])
            }
            
            CommandGroup(replacing: .appSettings) {
                Button("Preferences...") {
                    appDelegate.showPreferences()
                }
                .keyboardShortcut(",", modifiers: .command)
            }
            
            CommandGroup(replacing: .newItem) {
                Button("New Invoice") {
                    appDelegate.newInvoice()
                }
                .keyboardShortcut("n", modifiers: .command)
                
                Button("New Client") {
                    appDelegate.newClient()
                }
                .keyboardShortcut("c", modifiers: .command)
            }
            
            CommandGroup(replacing: .importExport) {
                Button("Export Data...") {
                    appDelegate.exportData()
                }
                .keyboardShortcut("e", modifiers: .command)
            }
            
            CommandGroup(replacing: .undoRedo) {
                Button("Undo") {
                    // Undo functionality
                }
                .keyboardShortcut("z", modifiers: .command)
                
                Button("Redo") {
                    // Redo functionality
                }
                .keyboardShortcut("z", modifiers: [.command, .shift])
            }
        }
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    var aboutWindow: NSWindow?
    var preferencesWindow: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let mode = UserDefaults.standard.string(forKey: "appearanceMode") ?? "dark"
        switch mode {
        case "light": NSApp.appearance = NSAppearance(named: .aqua)
        case "dark":  NSApp.appearance = NSAppearance(named: .darkAqua)
        default: break
        }
        setupMenuBar()
        SyncManager.shared.startAutoSync()
        Task { await APIService.shared.fetchExchangeRates() }
    }

    func applicationShouldSaveApplicationState(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationShouldRestoreApplicationState(_ sender: NSApplication) -> Bool {
        false
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        SyncManager.shared.stopAutoSync()
        CoreDataManager.shared.save()
    }
    
    // MARK: - Menu Actions
    func newInvoice() {
        NotificationCenter.default.post(name: .newInvoiceRequested, object: nil)
    }
    
    func newClient() {
        NotificationCenter.default.post(name: .newClientRequested, object: nil)
    }
    
    func exportData() {
        let savePanel = NSSavePanel()
        savePanel.nameFieldStringValue = "invoices_\(Date().formattedString()).json"
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                // Export logic
                print("Exporting to: \(url)")
            }
        }
    }
    
    func showAbout() {
        if aboutWindow == nil {
            let aboutView = AboutWindow()
            aboutWindow = NSWindow(
                contentRect: NSRect(x: 100, y: 100, width: 400, height: 300),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            aboutWindow?.isReleasedWhenClosed = false
            aboutWindow?.center()
            aboutWindow?.setFrameAutosaveName("AboutWindow")
            aboutWindow?.contentView = NSHostingView(rootView: aboutView)
            aboutWindow?.makeKeyAndOrderFront(nil)
        } else {
            aboutWindow?.makeKeyAndOrderFront(nil)
        }
    }
    
    func showPreferences() {
        if preferencesWindow == nil {
            let prefsView = PreferencesWindow()
            preferencesWindow = NSWindow(
                contentRect: NSRect(x: 100, y: 100, width: 500, height: 400),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            preferencesWindow?.isReleasedWhenClosed = false
            preferencesWindow?.center()
            preferencesWindow?.title = "Preferences"
            preferencesWindow?.setFrameAutosaveName("PreferencesWindow")
            preferencesWindow?.contentView = NSHostingView(rootView: prefsView)
            preferencesWindow?.makeKeyAndOrderFront(nil)
        } else {
            preferencesWindow?.makeKeyAndOrderFront(nil)
        }
    }
    
    private func setupMenuBar() {
        // Menu bar setup
    }
}
