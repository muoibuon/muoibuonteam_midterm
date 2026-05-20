import CoreData
import Foundation

class CoreDataManager {
    static let shared = CoreDataManager()

    let container: NSPersistentContainer
    let context: NSManagedObjectContext

    private init() {
        container = NSPersistentContainer(
            name: "B2BInvoice",
            managedObjectModel: CoreDataManager.createManagedObjectModel()
        )

        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context = container.viewContext
    }

    // MARK: - Programmatic CoreData Model
    private static func createManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        func makeAttr(_ name: String, _ type: NSAttributeType, optional: Bool = false) -> NSAttributeDescription {
            let a = NSAttributeDescription()
            a.name = name
            a.attributeType = type
            a.isOptional = optional
            return a
        }

        // Invoice entity
        let invoiceEntity = NSEntityDescription()
        invoiceEntity.name = "Invoice"
        invoiceEntity.managedObjectClassName = "Invoice"
        invoiceEntity.properties = [
            makeAttr("id", .UUIDAttributeType),
            makeAttr("invoiceNumber", .stringAttributeType),
            makeAttr("invoiceDate", .dateAttributeType),
            makeAttr("dueDate", .dateAttributeType),
            makeAttr("status", .stringAttributeType),
            makeAttr("subtotal", .doubleAttributeType),
            makeAttr("discountRate", .doubleAttributeType),
            makeAttr("discountAmount", .doubleAttributeType),
            makeAttr("subtotalAfterDiscount", .doubleAttributeType),
            makeAttr("vatRate", .doubleAttributeType),
            makeAttr("vatAmount", .doubleAttributeType),
            makeAttr("totalAmount", .doubleAttributeType),
            makeAttr("clientId", .UUIDAttributeType),
            makeAttr("clientName", .stringAttributeType),
            makeAttr("clientEmail", .stringAttributeType),
            makeAttr("clientPhone", .stringAttributeType),
            makeAttr("clientAddress", .stringAttributeType),
            makeAttr("paymentMethod", .stringAttributeType),
            makeAttr("paymentStatus", .stringAttributeType),
            makeAttr("paidAmount", .doubleAttributeType),
            makeAttr("paymentDate", .dateAttributeType, optional: true),
            makeAttr("description_field", .stringAttributeType),
            makeAttr("notes", .stringAttributeType),
            makeAttr("createdAt", .dateAttributeType),
            makeAttr("updatedAt", .dateAttributeType),
        ]

        // Client entity
        let clientEntity = NSEntityDescription()
        clientEntity.name = "Client"
        clientEntity.managedObjectClassName = "Client"
        clientEntity.properties = [
            makeAttr("id", .UUIDAttributeType),
            makeAttr("name", .stringAttributeType),
            makeAttr("email", .stringAttributeType),
            makeAttr("phone", .stringAttributeType),
            makeAttr("address", .stringAttributeType),
            makeAttr("city", .stringAttributeType),
            makeAttr("country", .stringAttributeType),
            makeAttr("taxCode", .stringAttributeType),
            makeAttr("companyName", .stringAttributeType),
            makeAttr("companyType", .stringAttributeType),
            makeAttr("industry", .stringAttributeType),
            makeAttr("website", .stringAttributeType),
            makeAttr("totalInvoices", .integer64AttributeType),
            makeAttr("totalRevenue", .doubleAttributeType),
            makeAttr("outstandingBalance", .doubleAttributeType),
            makeAttr("status", .stringAttributeType),
            makeAttr("creditLimit", .doubleAttributeType),
            makeAttr("paymentTerm", .integer32AttributeType),
            makeAttr("notes", .stringAttributeType),
            makeAttr("createdAt", .dateAttributeType),
            makeAttr("updatedAt", .dateAttributeType),
        ]

        model.entities = [invoiceEntity, clientEntity]
        return model
    }
    
    // MARK: - Save
    func save() {
        if context.hasChanges {
            do {
                try context.save()
                print("✅ Saved successfully")
            } catch {
                let nsError = error as NSError
                print("❌ Save error: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - Fetch
    func fetchRequest<T: NSManagedObject>(
        _ entityType: T.Type,
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor] = []
    ) -> [T] {
        let request = NSFetchRequest<T>(entityName: String(describing: entityType))
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Fetch error: \(error)")
            return []
        }
    }
    
    // MARK: - Delete
    func delete(_ object: NSManagedObject) {
        context.delete(object)
        save()
    }
    
    // MARK: - Create
    func createObject<T: NSManagedObject>(_ entityType: T.Type) -> T? {
        guard let entity = NSEntityDescription.entity(
            forEntityName: String(describing: entityType),
            in: context
        ) else {
            return nil
        }
        return T(entity: entity, insertInto: context)
    }
    
    // MARK: - Count
    func count<T: NSManagedObject>(
        _ entityType: T.Type,
        predicate: NSPredicate? = nil
    ) -> Int {
        let request = NSFetchRequest<T>(entityName: String(describing: entityType))
        request.predicate = predicate
        do {
            return try context.count(for: request)
        } catch {
            return 0
        }
    }
    
    // MARK: - Reset
    func resetAllData() {
        do {
            let model = container.managedObjectModel
            for entity in model.entities {
                guard let name = entity.name else { continue }
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: name)
                let batchDelete = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                try context.execute(batchDelete)
            }
            try context.save()
            print("✅ All data reset")
        } catch {
            print("❌ Reset error: \(error)")
        }
    }
}
