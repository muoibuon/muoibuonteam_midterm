import Foundation

struct ValidationHelper {
    // MARK: - Email Validation
    static func isValidEmail(_ email: String) -> Bool {
        let emailPattern = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
        let regex = try? NSRegularExpression(pattern: emailPattern)
        let range = NSRange(email.startIndex..., in: email)
        return regex?.firstMatch(in: email, range: range) != nil
    }
    
    // MARK: - Phone Validation
    static func isValidPhoneNumber(_ phone: String) -> Bool {
        let cleaned = phone.filter { $0.isNumber }
        return cleaned.count >= 10 && (cleaned.hasPrefix("0") || cleaned.hasPrefix("84"))
    }
    
    // MARK: - Amount Validation
    static func isValidAmount(_ amount: Double) -> Bool {
        return amount > 0 && amount <= 1_000_000_000
    }
    
    // MARK: - Invoice Number Validation
    static func isValidInvoiceNumber(_ number: String) -> Bool {
        let trimmed = number.trimmingCharacters(in: .whitespaces)
        return !trimmed.isEmpty && trimmed.count <= 50
    }
    
    // MARK: - Required Field
    static func isValidRequiredField(_ text: String) -> Bool {
        return !text.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    // MARK: - VAT Rate Validation
    static func isValidVATRate(_ rate: Double) -> Bool {
        return rate >= 0 && rate <= 0.3
    }
    
    // MARK: - Discount Rate Validation
    static func isValidDiscountRate(_ rate: Double) -> Bool {
        return rate >= 0 && rate <= 100
    }
}
