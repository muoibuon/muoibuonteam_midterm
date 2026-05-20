# Phân Tích OOP — Muoi B2B Invoice Manager

---

## Mục Lục

1. [Nguyên lý 1: Encapsulation — Đóng gói](#1-encapsulation--đóng-gói)
2. [Nguyên lý 2: Inheritance — Kế thừa](#2-inheritance--kế-thừa)
3. [Nguyên lý 3: Polymorphism — Đa hình](#3-polymorphism--đa-hình)
4. [Nguyên lý 4: Abstraction — Trừu tượng hóa](#4-abstraction--trừu-tượng-hóa)
5. [Mẫu Thiết Kế Singleton](#5-mẫu-thiết-kế-singleton)
6. [Sơ Đồ UML Class Diagram — OOP](#6-sơ-đồ-uml-class-diagram--oop)
7. [Tổng Kết — Bảng Áp Dụng OOP](#7-tổng-kết--bảng-áp-dụng-oop)

---

## 1. Encapsulation — Đóng Gói

### Áp Dụng Trong Dự Án

1: Lớp `Invoice` — Đóng gói tính toán tài chính

```
// File: Models/Models.swift — Dòng 6-62

public class Invoice: NSManagedObject {
    // Dữ liệu thô — lưu trong database
    @NSManaged public var subtotal: Double           // Tổng trước chiết khấu
    @NSManaged public var discountRate: Double       // Tỷ lệ chiết khấu (vd: 0.1 = 10%)
    @NSManaged public var discountAmount: Double     // Số tiền chiết khấu
    @NSManaged public var vatRate: Double            // Tỷ lệ VAT (vd: 0.1 = 10%)
    @NSManaged public var totalAmount: Double        // Tổng cuối cùng
    @NSManaged public var paidAmount: Double         // Số tiền đã thanh toán

    // Thuộc tính tính toán — ĐÓNG GÓI logic bên trong
    // Người dùng gọi "invoice.remainingAmount" mà không cần biết công thức
    public var remainingAmount: Double {
        return max(totalAmount - paidAmount, 0)   // Không âm (min = 0)
    }

    // ĐÓNG GÓI logic kiểm tra quá hạn
    public var isOverdue: Bool {
        return Date() > dueDate
            && paymentStatus != "paid"
            && status != "cancelled"
    }

    // ĐÓNG GÓI việc dịch trạng thái sang tiếng Việt
    public var statusDisplay: String {
        switch status {
        case "draft":     return "Nháp"
        case "pending":   return "Chờ xử lý"
        case "paid":      return "Đã thanh toán"
        case "cancelled": return "Hủy"
        default:          return status
        }
    }
}
```

Lợi ích: View chỉ cần gọi `invoice.isOverdue` — không cần biết bên trong so sánh ngày tháng như thế nào.

---

2: Lớp `CoreDataManager` — Đóng gói truy cập database

```
// File: Services/CoreDataManager.swift — Dòng 4-25

class CoreDataManager {
    static let shared = CoreDataManager()   // Chỉ 1 instance

    // private init() — ĐÓNG GÓI: không ai tạo được CoreDataManager mới
    private init() {
        container = NSPersistentContainer(...)   // Khởi tạo ẩn bên trong
        // Cấu hình merge policy, context... — người dùng không cần biết
    }

    // Phương thức công khai: đơn giản, dễ dùng
    func save() {   // Chỉ cần gọi .save(), không cần biết cách SQLite hoạt động
        if context.hasChanges {
            try context.save()
        }
    }

    func delete(_ object: NSManagedObject) {
        context.delete(object)
        save()   // Tự động lưu sau khi xóa — đóng gói logic
    }
}
```

**Sơ đồ Encapsulation:**
```
┌─────────────────────────────────────────┐
│              Invoice (Class)            │
│─────────────────────────────────────────│
│  [DỮ LIỆU BÊN TRONG - được bảo vệ]      │
│  - subtotal: Double                     │
│  - paidAmount: Double                   │
│  - totalAmount: Double                  │
│  - dueDate: Date                        │
│─────────────────────────────────────────│
│  [CỬA RA VÀO ĐƯỢC KIỂM SOÁT - public]   │
│  + remainingAmount → Double             │
│  + isOverdue → Bool                     │
│  + statusDisplay → String               │
└─────────────────────────────────────────┘
         ↑ View chỉ dùng phần này
```

---

## 2. Inheritance — Kế Thừa
### Áp Dụng Trong Dự Án

1: `Invoice` và `Client` kế thừa từ `NSManagedObject`

```
// File: Models/Models.swift

// LỚP CHA (từ Apple framework CoreData)
// NSManagedObject biết cách:
//   - Lưu vào SQLite
//   - Đọc từ SQLite
//   - Theo dõi thay đổi
//   - Quản lý quan hệ dữ liệu

class NSManagedObject {
    // Hàng trăm tính năng sẵn có từ Apple...
    func save() { ... }
    func delete() { ... }
    // ...
}

// LỚP CON 1 — Kế thừa TẤT CẢ tính năng của NSManagedObject
// và THÊM thuộc tính riêng cho hóa đơn
public class Invoice: NSManagedObject {    // ← ":" có nghĩa là "kế thừa từ"
    @NSManaged public var invoiceNumber: String   // Thêm mới
    @NSManaged public var totalAmount: Double     // Thêm mới
    @NSManaged public var clientName: String      // Thêm mới
    // ...

    // THÊM phương thức riêng
    public var isOverdue: Bool { ... }
    public var remainingAmount: Double { ... }
}

// LỚP CON 2 — Cũng kế thừa NSManagedObject
// nhưng có thuộc tính khác cho khách hàng
public class Client: NSManagedObject {    // ← cùng kế thừa
    @NSManaged public var companyName: String    // Thêm mới
    @NSManaged public var taxCode: String        // Thêm mới
    @NSManaged public var creditLimit: Double    // Thêm mới
    // ...

    // THÊM phương thức riêng
    public var creditAvailable: Double { ... }
    public var isActive: Bool { ... }
}
```

2: `AppDelegate` kế thừa từ `NSObject` và thực hiện `NSApplicationDelegate`

```
// File: App/B2BApp.swift — Dòng 66

class AppDelegate: NSObject, NSApplicationDelegate {
    //               ↑ Kế thừa từ NSObject (lớp cơ sở của macOS)
    //                             ↑ Tuân theo giao thức (sẽ học ở phần Abstraction)

    // AppDelegate được THỪA HƯỞNG từ NSObject:
    //   - Quản lý bộ nhớ tự động
    //   - Thông báo (Notification)
    //   - Kiểm tra bằng nhau (isEqual)

    // AppDelegate TỰ THÊM:
    var aboutWindow: NSWindow?       // Cửa sổ "Giới thiệu"
    var preferencesWindow: NSWindow? // Cửa sổ "Cài đặt"

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Chạy khi app khởi động
    }
}
```

**Sơ đồ Inheritance:**
```
              ┌─────────────────────────┐
              │      NSManagedObject    │  ← LỚP CHA (của Apple)
              │─────────────────────────│
              │ + save()                │
              │ + delete()              │
              │ + fetch()               │
              │ (nhiều tính năng khác)  │
              └────────────┬────────────┘
                           │ kế thừa
              ┌────────────┴────────────┐
              │                         │
    ┌─────────▼──────────┐  ┌──────────▼──────────┐
    │      Invoice       │  │        Client       │  ← LỚP CON
    │────────────────────│  │─────────────────────│
    │ (kế thừa tất cả)  │  │ (kế thừa tất cả)     │
    │ + invoiceNumber    │  │ + companyName       │
    │ + totalAmount      │  │ + taxCode           │
    │ + isOverdue        │  │ + creditLimit       │
    └────────────────────┘  └─────────────────────┘

Ký hiệu: ▲ = "kế thừa từ" (inheritance)
```

---

## 3. Polymorphism — Đa Hình
### Áp Dụng Trong Dự Án

1: `statusDisplay` — cùng tên, khác đối tượng

```
// Cả Invoice lẫn Client đều có statusDisplay
// nhưng trả về GIÁ TRỊ KHÁC NHAU

// Invoice.statusDisplay (Models.swift — dòng 53-61)
public var statusDisplay: String {
    switch status {
    case "draft":     return "Nháp"           // Trạng thái hóa đơn
    case "pending":   return "Chờ xử lý"
    case "paid":      return "Đã thanh toán"
    case "cancelled": return "Hủy"
    default:          return status
    }
}

// Client.statusDisplay (Models.swift — dòng 113-120)
public var statusDisplay: String {
    switch status {
    case "active":      return "Hoạt động"    // Trạng thái khách hàng
    case "inactive":    return "Không hoạt động"
    case "blacklisted": return "Cấm"
    default:            return status
    }
}
```

```
        ┌─────────────────────────────┐
        │     Gọi .statusDisplay      │
        └──────────────┬──────────────┘
                       │
         ┌─────────────┴─────────────┐
         │                           │
    Invoice                       Client
    .statusDisplay()              .statusDisplay()
         │                           │
    "Nháp" / "Chờ xử lý"       "Hoạt động" / "Cấm"
    "Đã thanh toán" / "Hủy"    "Không hoạt động"
         │                           │
    ─────────── Cùng tên, khác kết quả ───────────
```

2: Đa hình qua Generic (kiểu tổng quát)

```
// CoreDataManager.swift — Dòng 117-132
// Một phương thức fetchRequest() dùng cho cả Invoice LẪN Client

func fetchRequest<T: NSManagedObject>(   // T là kiểu bất kỳ kế thừa NSManagedObject
    _ entityType: T.Type,
    predicate: NSPredicate? = nil,
    sortDescriptors: [NSSortDescriptor] = []
) -> [T] {
    // Cùng code, nhưng T thay đổi tùy khi gọi
    let request = NSFetchRequest<T>(entityName: String(describing: entityType))
    request.predicate = predicate
    return try context.fetch(request)
}

// Cách dùng:
let invoices = CoreDataManager.shared.fetchRequest(Invoice.self)   // Lấy hóa đơn
let clients  = CoreDataManager.shared.fetchRequest(Client.self)    // Lấy khách hàng
//                                                  ↑ Đa hình: cùng hàm, kiểu khác nhau
```

3: Đa hình qua Protocol `ObservableObject`

```
// Ba lớp đều tuân theo ObservableObject nhưng thông báo dữ liệu khác nhau:

class APIService: ObservableObject {
    @Published var rates: [String: Double] = [:]   // Thông báo khi tỷ giá thay đổi
    @Published var countries: [String] = []
}

class SyncManager: ObservableObject {
    @Published var isSyncing = false               // Thông báo khi trạng thái sync thay đổi
    @Published var syncStatus: String = "Sẵn sàng"
}

class LocalizationManager: ObservableObject {
    @Published var currentLanguage: String = "vi"  // Thông báo khi ngôn ngữ thay đổi
}
// Cả 3 đều "ObservableObject" — View sẽ tự cập nhật khi chúng thay đổi
```

---

## 4. Abstraction — Trừu Tượng Hóa
### Áp Dụng Trong Dự Án

1: Protocol `Identifiable` — Trừu tượng hóa định danh**

```
// Models/Models.swift — dòng 38, 94

extension Invoice: Identifiable {}   // Invoice "tuân theo" giao thức Identifiable
extension Client: Identifiable {}    // Client cũng vậy

// Identifiable là một "hợp đồng" — định nghĩa CÁI GÌ, không nói LÀM THẾ NÀO:
// protocol Identifiable {
//     var id: ...   // Phải có thuộc tính "id"
// }

// Lợi ích: SwiftUI's List, ForEach tự biết cách hiển thị danh sách
// vì Invoice/Client đều Identifiable — có id duy nhất
```

2: `AppDelegate` tuân theo `NSApplicationDelegate`

```
// App/B2BApp.swift — Dòng 66

class AppDelegate: NSObject, NSApplicationDelegate {
    // NSApplicationDelegate là "hợp đồng" — định nghĩa:
    //   - applicationDidFinishLaunching() → chạy khi app khởi động
    //   - applicationWillTerminate()     → chạy khi app tắt
    //   - applicationShouldSaveState()   → có lưu trạng thái không?
    //
    // AppDelegate phải TRIỂN KHAI các phương thức này.
    // macOS sẽ TỰ ĐỘNG GỌI chúng đúng thời điểm.

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Thiết lập giao diện, bắt đầu sync, tải tỷ giá...
        setupMenuBar()
        SyncManager.shared.startAutoSync()
        Task { await APIService.shared.fetchExchangeRates() }
    }

    func applicationWillTerminate(_ notification: Notification) {
        SyncManager.shared.stopAutoSync()
        CoreDataManager.shared.save()   // Lưu dữ liệu trước khi tắt
    }
}
```

3: `ObservableObject` + `@Published` — Trừu tượng hóa phản ứng UI

```
// Services/APIService.swift — Dòng 21-28

class APIService: ObservableObject {
    @Published var rates: [String: Double] = [:]   // "published" = thông báo cho UI

    // Khi rates thay đổi → SwiftUI TỰ ĐỘNG cập nhật màn hình
    // → Developer không cần viết code "cập nhật UI thủ công"
    // → Đây là TRỪU TƯỢNG HÓA quá trình cập nhật giao diện
}
```

**Sơ đồ Abstraction — Protocol (Giao thức):**

```
             ┌────────────────────────────┐
             │   <<Protocol>>             │
             │   ObservableObject         │   ← Hợp đồng (trừu tượng)
             │────────────────────────────│
             │  CÁI GÌ cần có:            │
             │  @Published var ...        │
             │  objectWillChange signal   │
             └───────────┬────────────────┘
                         │ tuân theo (conforms to)
          ┌──────────────┼──────────────┐
          ▼              ▼              ▼
  ┌───────────┐  ┌────────────┐  ┌─────────────────┐
  │APIService │  │SyncManager │  │LocalizationMgr  │
  │           │  │            │  │                 │
  │ @Published│  │ @Published │  │ @Published      │
  │ rates     │  │ isSyncing  │  │ currentLanguage │
  └───────────┘  └────────────┘  └─────────────────┘
  Đều là ObservableObject → View tự cập nhật khi data thay đổi
```

---

## 5. Mẫu Thiết Kế Singleton
### Áp Dụng Trong Dự Án — 3 Singleton

```
// 1. CoreDataManager.swift — Dòng 4-25
class CoreDataManager {
    static let shared = CoreDataManager()   // ← Đây là đối tượng duy nhất
    private init() { ... }                  // ← private = không ai tạo mới được
    //    ↑ Khóa constructor lại
}

// Cách dùng:
CoreDataManager.shared.save()              // Luôn dùng cùng 1 đối tượng
CoreDataManager.shared.fetchRequest(...)

// 2. APIService.swift — Dòng 21-34
class APIService: ObservableObject {
    static let shared = APIService()
    private init() {}
}

// 3. SyncManager.swift — Dòng 3-15
class SyncManager: ObservableObject {
    static let shared = SyncManager()
    private init() { loadLastSyncDate() }
}
```

Sơ đồ Singleton:
```
  View A ──────────────────────────────────┐
                                           ▼
  View B ───────────────────►  CoreDataManager.shared  ◄──── 1 đối tượng duy nhất
                                           │
  View C ──────────────────────────────────┘
                                           │
                                           ▼
                                    SQLite Database
```

---

## 6. Sơ Đồ UML Class Diagram — OOP

> Sơ đồ này thể hiện toàn bộ 4 nguyên lý OOP và mẫu Singleton trong dự án.

```
  ┌─────────────────────────────────────────────────────────────────────────┐
  │                    KÝ HIỆU UML CLASS DIAGRAM                           │
  │  <<interface>> = Giao thức / Protocol (Abstraction)                    │
  │  ──▷ = Kế thừa (Inheritance)                                           │
  │  ···▷ = Thực hiện giao thức (Realization/Abstraction)                  │
  │  ──── = Quan hệ sử dụng (Association)                                  │
  │  ◆─── = Quan hệ chứa đựng (Composition)                                │
  └─────────────────────────────────────────────────────────────────────────┘

         ┌───────────────────────────┐
         │     <<interface>>         │
         │   NSApplicationDelegate   │   ← Abstraction (Giao thức)
         │───────────────────────────│
         │ + appDidFinishLaunching() │
         │ + appWillTerminate()      │
         └─────────────┬─────────────┘
                       │ ···▷ (thực hiện)
         ┌─────────────▼─────────────┐
         │        AppDelegate        │
         │───────────────────────────│
         │ - aboutWindow: NSWindow?  │
         │ - prefsWindow: NSWindow?  │   ← Encapsulation (thuộc tính private)
         │───────────────────────────│
         │ + newInvoice()            │
         │ + newClient()             │
         │ + showAbout()             │
         └─────────────┬─────────────┘
                       │ sử dụng
         ┌─────────────┼─────────────────────┐
         ▼             ▼                     ▼
┌──────────────┐  ┌──────────────┐  ┌────────────────────┐
│ <<Singleton>>│  │ <<Singleton>>│  │   <<Singleton>>    │
│CoreDataMgr   │  │ APIService   │  │   SyncManager      │
│──────────────│  │──────────────│  │────────────────────│
│ +shared ◄────────────── Chỉ 1 instance  ──────────────►│
│ -init()      │  │ -init()      │  │ -init()            │
│──────────────│  │──────────────│  │────────────────────│
│ +save()      │  │+fetchRates() │  │ +startAutoSync()   │
│ +fetch<T>()  │  │+vietQRURL()  │  │ +stopAutoSync()    │
│ +delete()    │  │+toVND()      │  │ +manualSync()      │
└──────┬───────┘  └──────────────┘  └────────────────────┘
       │ quản lý (Composition ◆)
       ├──────────────────────────────────────┐
       ▼                                      ▼
┌──────────────────────────┐   ┌──────────────────────────┐
│  <<NSManagedObject>>     │   │  <<NSManagedObject>>     │
│        Invoice           │   │        Client            │
│──────────────────────────│   │──────────────────────────│
│ (Inheritance từ NSMgdObj)│   │ (Inheritance từ NSMgdObj)│
│──────────────────────────│   │──────────────────────────│
│ + id: UUID               │   │ + id: UUID               │
│ + invoiceNumber: String  │   │ + companyName: String    │
│ + totalAmount: Double    │   │ + creditLimit: Double    │
│──────────────────────────│   │──────────────────────────│
│ + remainingAmount        │   │ + creditAvailable        │  ← Encapsulation
│ + isOverdue: Bool        │   │ + isActive: Bool         │
│ + statusDisplay: String  │   │ + statusDisplay: String  │  ← Polymorphism
└──────────────────────────┘   └──────────────────────────┘
          │ tuân theo                        │ tuân theo
          ▼                                  ▼
  ┌───────────────────┐             ┌───────────────────┐
  │   <<interface>>   │             │   <<interface>>   │
  │   Identifiable    │             │   Identifiable    │  ← Abstraction
  │─────────────────  │             │───────────────────│
  │  var id: ...      │             │  var id: ...      │
  └───────────────────┘             └───────────────────┘
```

---

## 7. Tổng Kết — Bảng Áp Dụng OOP

| Nguyên Lý | Định Nghĩa Đơn Giản | Áp Dụng Trong Dự Án | File / Dòng Code |
| --- | --- | --- | --- |
| **Encapsulation** | Ẩn dữ liệu, chỉ mở cửa kiểm soát | `isOverdue`, `remainingAmount`, `private init()` | Models.swift:45-61, CoreDataManager.swift:11 |
| **Inheritance** | Con thừa hưởng cha | `Invoice: NSManagedObject`, `Client: NSManagedObject`, `AppDelegate: NSObject` | Models.swift:6, 66; B2BApp.swift:66 |
| **Polymorphism** | Cùng tên, hành vi khác | `statusDisplay` trên Invoice vs Client; `fetchRequest<T>()` generic | Models.swift:53, 113; CoreDataManager.swift:117 |
| **Abstraction** | Ẩn phức tạp, chỉ hiện cái cần | Protocol `Identifiable`, `ObservableObject`, `NSApplicationDelegate` | Models.swift:38, 94; APIService.swift:21 |
| **Singleton** *(mẫu thiết kế)* | 1 đối tượng duy nhất | `CoreDataManager.shared`, `APIService.shared`, `SyncManager.shared` | Tất cả Services |

