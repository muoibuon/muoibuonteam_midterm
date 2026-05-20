import Foundation
import CoreData

// MARK: - Invoice Entity
@objc(Invoice)
public class Invoice: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var invoiceNumber: String
    @NSManaged public var invoiceDate: Date
    @NSManaged public var dueDate: Date
    @NSManaged public var status: String
    
    @NSManaged public var subtotal: Double
    @NSManaged public var discountRate: Double
    @NSManaged public var discountAmount: Double
    @NSManaged public var subtotalAfterDiscount: Double
    @NSManaged public var vatRate: Double
    @NSManaged public var vatAmount: Double
    @NSManaged public var totalAmount: Double
    
    @NSManaged public var clientId: UUID
    @NSManaged public var clientName: String
    @NSManaged public var clientEmail: String
    @NSManaged public var clientPhone: String
    @NSManaged public var clientAddress: String
    
    @NSManaged public var paymentMethod: String
    @NSManaged public var paymentStatus: String
    @NSManaged public var paidAmount: Double
    @NSManaged public var paymentDate: Date?
    
    @NSManaged public var description_field: String
    @NSManaged public var notes: String
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
}

extension Invoice: Identifiable {}

extension Invoice {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Invoice> {
        return NSFetchRequest<Invoice>(entityName: "Invoice")
    }
    
    public var remainingAmount: Double {
        return max(totalAmount - paidAmount, 0)
    }
    
    public var isOverdue: Bool {
        return Date() > dueDate && paymentStatus != "paid" && status != "cancelled"
    }
    
    public var statusDisplay: String {
        switch status {
        case "draft": return "Nháp"
        case "pending": return "Chờ xử lý"
        case "paid": return "Đã thanh toán"
        case "cancelled": return "Hủy"
        default: return status
        }
    }
}

// MARK: - Client Entity
@objc(Client)
public class Client: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var email: String
    @NSManaged public var phone: String
    @NSManaged public var address: String
    @NSManaged public var city: String
    @NSManaged public var country: String
    @NSManaged public var taxCode: String
    
    @NSManaged public var companyName: String
    @NSManaged public var companyType: String
    @NSManaged public var industry: String
    @NSManaged public var website: String
    
    @NSManaged public var totalInvoices: Int64
    @NSManaged public var totalRevenue: Double
    @NSManaged public var outstandingBalance: Double
    
    @NSManaged public var status: String
    @NSManaged public var creditLimit: Double
    @NSManaged public var paymentTerm: Int32
    
    @NSManaged public var notes: String
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
}

extension Client: Identifiable {}

extension Client {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Client> {
        return NSFetchRequest<Client>(entityName: "Client")
    }
    
    public var displayName: String {
        return companyName.isEmpty ? name : companyName
    }
    
    public var isActive: Bool {
        return status == "active"
    }
    
    public var creditAvailable: Double {
        return max(creditLimit - outstandingBalance, 0)
    }
    
    public var statusDisplay: String {
        switch status {
        case "active": return "Hoạt động"
        case "inactive": return "Không hoạt động"
        case "blacklisted": return "Cấm"
        default: return status
        }
    }
}
