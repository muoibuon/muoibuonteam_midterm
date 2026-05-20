import Foundation
import AppKit

struct AppConstants {
    // MARK: - Banks for VietQR
    struct Banks {
        struct Bank: Identifiable {
            let id: String; let name: String; let shortName: String
        }
        static let all: [Bank] = [
            Bank(id: "VCB",  name: "Vietcombank",       shortName: "VCB"),
            Bank(id: "TCB",  name: "Techcombank",        shortName: "TCB"),
            Bank(id: "BIDV", name: "BIDV",               shortName: "BIDV"),
            Bank(id: "VTB",  name: "VietinBank",         shortName: "VTB"),
            Bank(id: "MB",   name: "MB Bank",            shortName: "MB"),
            Bank(id: "ACB",  name: "ACB",                shortName: "ACB"),
            Bank(id: "TPB",  name: "TPBank",             shortName: "TPB"),
            Bank(id: "VPB",  name: "VPBank",             shortName: "VPB"),
            Bank(id: "OCB",  name: "OCB",                shortName: "OCB"),
            Bank(id: "SHB",  name: "SHB",                shortName: "SHB"),
            Bank(id: "MSB",  name: "MSB",                shortName: "MSB"),
            Bank(id: "HDBank", name: "HDBank",           shortName: "HDB"),
        ]
    }

    // MARK: - Supported Currencies
    struct Currencies {
        static let all = ["VND", "USD", "EUR", "JPY", "SGD", "KRW", "CNY", "GBP", "AUD"]
        static let symbols: [String: String] = [
            "VND": "₫", "USD": "$", "EUR": "€", "JPY": "¥",
            "SGD": "S$", "KRW": "₩", "CNY": "¥", "GBP": "£", "AUD": "A$"
        ]
        // AppStorage keys for bank settings
        static let bankIdKey      = "bankId"
        static let accountNoKey   = "accountNo"
        static let accountNameKey = "accountName"
        static let defaultBankId  = "TCB"
    }
    // App Info
    static let appName = "Muoi"
    static let appVersion = "1.0.0"
    static let appBuild = "2024.001"
    
    // Window Sizes
    struct Window {
        static let minWidth: CGFloat = 800
        static let minHeight: CGFloat = 600
        static let defaultWidth: CGFloat = 1200
        static let defaultHeight: CGFloat = 800
    }
    
    // Sidebar
    struct Sidebar {
        static let width: CGFloat = 250
        static let minWidth: CGFloat = 150
        static let maxWidth: CGFloat = 400
    }
    
    // Colors
    struct Colors {
        static let primary = NSColor(red: 0.122, green: 0.306, blue: 0.471, alpha: 1.0)
        static let accent = NSColor(red: 0.753, green: 0.0, blue: 0.0, alpha: 1.0)
        static let success = NSColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1.0)
        static let warning = NSColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
        static let danger = NSColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0)
    }
    
    // API Configuration
    struct API {
        static let baseURL = "http://b2b-server.local/api"
        static let timeout: TimeInterval = 30.0
        static let retryCount = 3
    }
    
    // Finance Settings
    struct Finance {
        static let defaultVATRate = 0.1
        static let defaultDiscountRate = 0.0
        static let currencyCode = "VND"
        static let currencySymbol = "₫"
    }
    
    // Sync Settings
    struct Sync {
        static let interval: TimeInterval = 300
        static let maxRetries = 3
        static let isAutoSyncEnabled = true
    }
    
    // Pagination
    struct Pagination {
        static let pageSize = 50
        static let maxPageSize = 100
    }
    
    // Date Formats
    struct DateFormat {
        static let short = "dd/MM/yyyy"
        static let long = "dd/MM/yyyy HH:mm:ss"
        static let monthYear = "MMMM yyyy"
    }
    
    // Keyboard Shortcuts
    struct Shortcuts {
        static let newInvoice = "n"
        static let newClient = "c"
        static let search = "f"
        static let export = "e"
        static let settings = ","
        static let quit = "q"
    }
}
