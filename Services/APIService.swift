import Foundation
import SwiftUI

// MARK: - API Response Models
private struct ExchangeRatesResponse: Codable {
    let result: String
    let rates: [String: Double]
}

private struct CountryItem: Codable {
    let name: CountryName
    struct CountryName: Codable { let common: String }
}

// MARK: - APIService
// Integrates 3 free APIs (no key required):
//   1. open.er-api.com     — live exchange rates (USD base)
//   2. img.vietqr.io       — VietQR bank transfer QR images
//   3. restcountries.com   — country list
@MainActor
class APIService: ObservableObject {
    static let shared = APIService()

    // Exchange rates
    @Published var rates: [String: Double] = [:]
    @Published var isLoadingRates = false
    @Published var ratesError: String?
    @Published var lastRatesUpdate: Date?

    // Countries
    @Published var countries: [String] = []
    @Published var isLoadingCountries = false

    private init() {}

    // ── Exchange Rates ──────────────────────────────────
    // Source: https://open.er-api.com/v6/latest/USD
    // Free tier, no API key, ~1500 req/month
    func fetchExchangeRates() async {
        guard !isLoadingRates else { return }
        isLoadingRates = true
        ratesError = nil
        defer { isLoadingRates = false }

        guard let url = URL(string: "https://open.er-api.com/v6/latest/USD") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response  = try JSONDecoder().decode(ExchangeRatesResponse.self, from: data)
            if response.result == "success" {
                rates = response.rates
                lastRatesUpdate = Date()
            }
        } catch {
            ratesError = "Không thể tải tỷ giá"
        }
    }

    // Convert any amount to VND using USD as bridge
    func toVND(amount: Double, from currency: String) -> Double {
        guard currency != "VND",
              let usdToVND = rates["VND"],
              let usdToSrc = rates[currency],
              usdToSrc > 0 else { return amount }
        return (amount / usdToSrc) * usdToVND
    }

    func fromVND(amount: Double, to currency: String) -> Double {
        guard currency != "VND",
              let usdToVND = rates["VND"], usdToVND > 0,
              let usdToDst = rates[currency] else { return amount }
        return (amount / usdToVND) * usdToDst
    }

    // "1 USD ≈ 24,850₫"
    func rateDescription(for currency: String) -> String {
        guard currency != "VND",
              let usdToVND = rates["VND"],
              let usdToCur = rates[currency],
              usdToCur > 0 else { return "" }
        let rate = usdToVND / usdToCur
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.maximumFractionDigits = 0
        let formatted = fmt.string(from: NSNumber(value: rate)) ?? "\(Int(rate))"
        return "1 \(currency) ≈ \(formatted)₫"
    }

    // ── VietQR ──────────────────────────────────────────
    // Source: https://img.vietqr.io — free, no API key
    // Returns a PNG image URL ready for AsyncImage
    func vietQRURL(bankId: String, accountNo: String,
                   amount: Double, info: String, accountName: String) -> URL? {
        guard !bankId.isEmpty, !accountNo.isEmpty else { return nil }
        var comps = URLComponents(string: "https://img.vietqr.io/image/\(bankId)-\(accountNo)-compact2.png")
        comps?.queryItems = [
            URLQueryItem(name: "amount",      value: "\(Int(amount))"),
            URLQueryItem(name: "addInfo",     value: info),
            URLQueryItem(name: "accountName", value: accountName),
        ]
        return comps?.url
    }

    // ── Countries ───────────────────────────────────────
    // Source: https://restcountries.com — free, no API key
    func fetchCountries() async {
        guard countries.isEmpty, !isLoadingCountries else { return }
        isLoadingCountries = true
        defer { isLoadingCountries = false }

        guard let url = URL(string: "https://restcountries.com/v3.1/all?fields=name") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let items = try JSONDecoder().decode([CountryItem].self, from: data)
            var list = items.map { $0.name.common }.sorted()
            // Push Vietnam to top
            list.removeAll { $0 == "Vietnam" }
            countries = ["Việt Nam"] + list
        } catch {
            countries = ["Việt Nam", "United States", "Japan", "South Korea",
                         "China", "Germany", "France", "United Kingdom", "Singapore", "Australia"]
        }
    }
}
