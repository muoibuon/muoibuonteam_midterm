# BÁO CÁO KIỂM THỬ
## Dự Án: Muoi — B2B Invoice Manager

---

| Thông tin | Chi tiết |
|-----------|---------|
| **Tên dự án** | Muoi — Ứng dụng quản lý hóa đơn B2B |
| **Phiên bản** | 1.0.0 (Build 2024.001) |
| **Nền tảng** | macOS 13.0+ (Ventura trở lên) |
| **Công nghệ** | Swift 5.9 · SwiftUI · CoreData |
| **Ngày báo cáo** | 14 tháng 04 năm 2026 |
| **Người thực hiện** | Muoi |

---

## Mục Lục

1. [Tổng Quan Kiểm Thử](#1-tổng-quan-kiểm-thử)
2. [Phạm Vi Kiểm Thử](#2-phạm-vi-kiểm-thử)
3. [Kết Quả Kiểm Thử Chức Năng](#3-kết-quả-kiểm-thử-chức-năng)
4. [Ưu Điểm Của Dự Án](#4-ưu-điểm-của-dự-án)
5. [Nhược Điểm Của Dự Án](#5-nhược-điểm-của-dự-án)
6. [Phân Tích Rủi Ro](#6-phân-tích-rủi-ro)
7. [Đề Xuất Cải Tiến](#7-đề-xuất-cải-tiến)
8. [Kết Luận](#8-kết-luận)

---

## 1. Tổng Quan Kiểm Thử

### 1.1 Mục Tiêu Kiểm Thử

Báo cáo này đánh giá toàn diện chất lượng phần mềm **Muoi B2B Invoice Manager** thông qua:
- Kiểm thử chức năng (Functional Testing)
- Kiểm thử giao diện người dùng (UI Testing)
- Kiểm thử tích hợp API (Integration Testing)
- Đánh giá kiến trúc code (Code Review)

### 1.2 Phương Pháp Kiểm Thử

| Phương Pháp | Mô Tả |
|-------------|-------|
| **Black-box Testing** | Kiểm thử theo chức năng, không xem code |
| **White-box Testing** | Phân tích code trực tiếp |
| **Exploratory Testing** | Khám phá tự do, tìm lỗi không ngờ |
| **Regression Testing** | Kiểm tra tính năng cũ sau khi thêm mới |

### 1.3 Môi Trường Kiểm Thử

| Thành Phần | Thông Tin |
|-----------|----------|
| Hệ điều hành | macOS 13.0 Ventura |
| Xcode | 15.0+ |
| Swift | 5.9 |
| Thiết bị | MacBook Pro / Mac mini |
| Kết nối Internet | Cần thiết cho API (tỷ giá, VietQR) |

---

## 2. Phạm Vi Kiểm Thử

```
┌─────────────────────────────────────────────────────────┐
│                 PHẠM VI KIỂM THỬ                        │
│                                                         │
│  Trong phạm vi:                                         │
│     • Quản lý hóa đơn (tạo, sửa, xóa, tìm kiếm)         │
│     • Quản lý khách hàng (CRUD)                         │
│     • Tính toán tài chính (VAT, chiết khấu, tổng)       │
│     • Dashboard thống kê                                │
│     • Giao diện sáng/tối                                │
│     • Đa ngôn ngữ Việt/Anh                              │
│     • Tích hợp API VietQR                               │
│     • Tích hợp API tỷ giá                               │
│     • Lưu trữ dữ liệu CoreData                          │
│                                                         │
│  Ngoài phạm vi:                                         │
│     • Kiểm thử tự động (Unit Test / UI Test chưa có)    │
│     • Kiểm thử đa người dùng                            │
│     • Kiểm thử bảo mật chuyên sâu                       │
│     • Kiểm thử hiệu năng quy mô lớn (>10,000 hóa đơn)   │
└─────────────────────────────────────────────────────────┘
```

---

## 3. Kết Quả Kiểm Thử Chức Năng

### 3.1 Module Hóa Đơn

| ID | Trường Hợp Kiểm Thử | Kết Quả | Ghi Chú |
|----|---------------------|---------|---------|
| TC-01 | Tạo hóa đơn mới với đầy đủ thông tin |  PASS | Lưu vào CoreData thành công |
| TC-02 | Tính VAT 10% tự động |  PASS | Công thức chính xác |
| TC-03 | Áp dụng chiết khấu |  PASS | subtotal → discount → VAT đúng thứ tự |
| TC-04 | Hóa đơn tự động đánh dấu quá hạn |  PASS | isOverdue hoạt động |
| TC-05 | Tìm kiếm hóa đơn theo tên KH |  PASS | |
| TC-06 | Lọc hóa đơn theo trạng thái |  PASS | |
| TC-07 | Ghi nhận thanh toán một phần |  PASS | remainingAmount tính đúng |
| TC-08 | Xóa hóa đơn |  PASS | Xóa khỏi CoreData |
| TC-09 | Tạo hóa đơn khi chưa chọn khách hàng | WARN | Cần validation rõ hơn |
| TC-10 | Hóa đơn số âm |  WARN | Chưa có validation giới hạn dưới |

### 3.2 Module Khách Hàng

| ID | Trường Hợp Kiểm Thử | Kết Quả | Ghi Chú |
|----|---------------------|---------|---------|
| TC-11 | Thêm khách hàng mới |  PASS | |
| TC-12 | Chỉnh sửa thông tin KH |  PASS | |
| TC-13 | Xóa khách hàng |  PASS | |
| TC-14 | Kiểm tra hạn mức tín dụng |  PASS | creditAvailable tính đúng |
| TC-15 | Tìm kiếm khách hàng |  PASS | |
| TC-16 | Email trùng lặp |  FAIL | Không có validation kiểm tra email trùng |
| TC-17 | Mã số thuế format |  WARN | Không validate format MST Việt Nam |

### 3.3 Module API & VietQR

| ID | Trường Hợp Kiểm Thử | Kết Quả | Ghi Chú |
|----|---------------------|---------|---------|
| TC-18 | Tải tỷ giá khi có mạng |  PASS | open.er-api.com hoạt động |
| TC-19 | Xử lý khi mất mạng |  PASS | Hiển thị thông báo lỗi |
| TC-20 | Sinh mã QR VietQR |  PASS | img.vietqr.io trả về ảnh PNG |
| TC-21 | QR với số tiền 0 đồng |  WARN | Không block, tạo QR với amount=0 |
| TC-22 | Danh sách quốc gia |  PASS | Fallback khi lỗi mạng |

### 3.4 Module Giao Diện

| ID | Trường Hợp Kiểm Thử | Kết Quả | Ghi Chú |
|----|---------------------|---------|---------|
| TC-23 | Chuyển dark/light mode | PASS | Tức thì, không cần restart |
| TC-24 | Chuyển ngôn ngữ Việt ↔ Anh | PASS | LocalizationManager hoạt động |
| TC-25 | Resize cửa sổ |  PASS | Layout responsive |
| TC-26 | Phím tắt Cmd+N (hóa đơn mới) |  PASS | |
| TC-27 | Phím tắt Cmd+, (cài đặt) |  PASS | |

**Tổng kết:** 22/27 test PASS (81%) | 1 FAIL | 4 WARN

---

## 4. Ưu Điểm Của Dự Án

### 4.1 Kiến Trúc & Kỹ Thuật

#### Ưu Điểm 1: Kiến Trúc Phân Tầng Rõ Ràng
Dự án phân chia rõ ràng thành các tầng **Views → Services → Models**. Mỗi tầng có trách nhiệm riêng biệt, dễ bảo trì.

```
Views/          → Chỉ chứa giao diện, không xử lý logic
Services/       → Xử lý nghiệp vụ, không biết đến UI
Models/         → Chỉ chứa cấu trúc dữ liệu
Utilities/      → Công cụ dùng chung
```
*Lợi ích: Khi cần sửa giao diện, không ảnh hưởng đến logic. Khi sửa logic, không phải đụng đến UI.*

---

#### Ưu Điểm 2: Mẫu Thiết Kế Singleton Đúng Cách
Ba Singleton (`CoreDataManager`, `APIService`, `SyncManager`) đều có:
- `static let shared` — điểm truy cập duy nhất
- `private init()` — không ai tạo instance mới
- Thread-safe với `@MainActor` trên APIService

```swift
// Dùng đơn giản, nhất quán ở mọi nơi
CoreDataManager.shared.save()
APIService.shared.fetchExchangeRates()
SyncManager.shared.startAutoSync()
```

---

#### Ưu Điểm 3: Không Cần File .xcdatamodeld (Programmatic CoreData)
`CoreDataManager` định nghĩa model programmatically (bằng code) thay vì XML, giúp:
- Dễ kiểm soát qua Git (không có file binary)
- Dễ đọc, dễ sửa đổi schema
- Không phụ thuộc vào Xcode Interface Builder

---

#### Ưu Điểm 4: Generic Method Tái Sử Dụng Cao
```swift
func fetchRequest<T: NSManagedObject>(_ entityType: T.Type, ...) -> [T]
func createObject<T: NSManagedObject>(_ entityType: T.Type) -> T?
```
Một phương thức dùng cho tất cả entity — giảm code trùng lặp đáng kể.

---

#### Ưu Điểm 5: Sử Dụng API Miễn Phí, Không Cần API Key
3 API được tích hợp đều **miễn phí, không cần đăng ký**:
- `open.er-api.com` — tỷ giá thời gian thực
- `img.vietqr.io` — mã QR chuyển khoản ngân hàng Việt Nam
- `restcountries.com` — danh sách quốc gia

*Lợi ích: Giảm chi phí vận hành, dễ triển khai cho người dùng mới.*

---

### 4.2 Tính Năng & Người Dùng

#### Ưu Điểm 6: Hỗ Trợ Đa Ngôn Ngữ Tức Thì
`LocalizationManager` cho phép đổi ngôn ngữ Việt ↔ Anh mà **không cần restart ứng dụng** — hiếm có trong app macOS truyền thống.

---

#### Ưu Điểm 7: Giao Diện Sáng/Tối Linh Hoạt
Hỗ trợ đầy đủ dark mode / light mode với lưu preference vào `UserDefaults` — áp dụng ngay khi mở app.

---

#### Ưu Điểm 8: Tính Năng VietQR Độc Đáo
Tích hợp VietQR trực tiếp trong hóa đơn là điểm khác biệt lớn so với các phần mềm hóa đơn thông thường — phù hợp hoàn toàn với thị trường Việt Nam.

---

#### Ưu Điểm 9: Tính Toán Tài Chính Chuẩn Xác
Công thức tính toán tuân đúng chuẩn kế toán Việt Nam:
```
Subtotal → Chiết khấu → Subtotal sau chiết khấu → VAT → Tổng cuối
```

---

#### Ưu Điểm 10: Lưu Dữ Liệu Local Không Cần Internet
CoreData + SQLite đảm bảo dữ liệu **luôn có sẵn** dù không có mạng. Đây là yếu tố quan trọng cho doanh nghiệp nhỏ.

---

## 5. Nhược Điểm Của Dự Án

### 5.1 Thiếu Unit Test & UI Test

**Mức độ: NGHIÊM TRỌNG**

Toàn bộ dự án không có một file test nào (`*Tests.swift`). Đây là thiếu sót lớn nhất:
- Không thể tự động phát hiện lỗi khi refactor
- Không thể đảm bảo tính toán tài chính luôn đúng sau mỗi thay đổi
- Không tuân theo tiêu chuẩn phát triển phần mềm chuyên nghiệp

**Giải pháp:** Viết minimum test coverage 60% cho Models và Services.

---

### 5.2 Không Có Validation Đầy Đủ

**Mức độ: CAO**

`ValidationHelper.swift` tồn tại nhưng validation thực tế còn yếu:

| Trường | Vấn Đề |
|--------|--------|
| Email khách hàng | Không kiểm tra trùng lặp |
| Mã số thuế | Không validate format 10-13 số |
| Số tiền hóa đơn | Không chặn giá trị âm |
| Ngày hết hạn | Không cảnh báo khi đặt trước ngày tạo |
| Số điện thoại | Không kiểm tra format Việt Nam |

---

### 5.3 SyncManager Chưa Có Backend Thực

**Mức độ: CAO**

`SyncManager.performSync()` hiện chỉ **giả lập** (simulate) việc đồng bộ bằng `Thread.sleep(1.0)`:

```swift
// Services/SyncManager.swift — Dòng 38-56
private func performSync() {
    // ...
    DispatchQueue.global(qos: .background).async { [weak self] in
        Thread.sleep(forTimeInterval: 1.0)   // ← CHỈ ĐỢI 1 GIÂY, KHÔNG LÀM GÌ THỰC SỰ
        DispatchQueue.main.async {
            self?.isSyncing = false
            self?.syncStatus = "Đã đồng bộ"   // ← Fake status
        }
    }
}
```

*Hậu quả: Người dùng nghĩ dữ liệu đã được đồng bộ nhưng thực ra chưa. Đây là lỗi UX nghiêm trọng.*

---

### 5.4 Undo/Redo Chưa Hoạt Động

**Mức độ: TRUNG BÌNH**

Menu Undo (Cmd+Z) và Redo (Cmd+Shift+Z) được định nghĩa nhưng không có xử lý:

```swift
// App/B2BApp.swift — Dòng 52-59
Button("Undo") {
    // Undo functionality   ← TRỐNG RỖNG
}
Button("Redo") {
    // Undo functionality   ← TRỐNG RỖNG
}
```

*Người dùng nhấn Cmd+Z kỳ vọng được hoàn tác nhưng không có gì xảy ra.*

---

### 5.5 Export Data Chưa Hoàn Thiện

**Mức độ: TRUNG BÌNH**

Chức năng xuất dữ liệu (Cmd+E) chỉ in ra console, không thực sự ghi file:

```swift
// App/B2BApp.swift — Dòng 106-112
savePanel.begin { response in
    if response == .OK, let url = savePanel.url {
        print("Exporting to: \(url)")   // ← CHỈ IN LOG, KHÔNG GHI FILE
    }
}
```

---

### 5.6 Không Có Phân Trang Thực Sự

**Mức độ: TRUNG BÌNH**

`AppConstants.Pagination.pageSize = 50` được định nghĩa nhưng không được sử dụng trong `fetchRequest()`. Khi có hàng nghìn hóa đơn, toàn bộ dữ liệu sẽ được nạp vào bộ nhớ cùng lúc.

---

### 5.7 Thiếu Xác Nhận Trước Khi Xóa

**Mức độ: TRUNG BÌNH**

Chưa có dialog "Bạn có chắc muốn xóa?" trước khi xóa hóa đơn hoặc khách hàng — dễ gây mất dữ liệu do thao tác nhầm.

---

### 5.8 Invoice Không Lưu Dòng Sản Phẩm (Line Items)

**Mức độ: CAO**

Model `Invoice` lưu `subtotal` nhưng không có entity `InvoiceItem` để lưu từng dòng sản phẩm/dịch vụ:

```
Invoice
├── id
├── invoiceNumber
├── subtotal        ← Chỉ lưu tổng, không lưu từng sản phẩm
├── totalAmount
└── ...             ← Không có: items, products, line items
```

*Hậu quả: Không thể in chi tiết hóa đơn theo từng mặt hàng, không đáp ứng yêu cầu kế toán thực tế.*

---

### 5.9 Không Có Tính Năng In / Xuất PDF

**Mức độ: CAO**

Một phần mềm quản lý hóa đơn mà **không thể in hoặc xuất hóa đơn ra PDF** là thiếu sót lớn cho mục đích kinh doanh thực tế.

---

### 5.10 Hardcode Hằng Số Tài Chính

**Mức độ: THẤP**

VAT mặc định (10%) và chiết khấu mặc định (0%) được hardcode trong Constants:

```swift
struct Finance {
    static let defaultVATRate = 0.1     // 10% VAT — Luật Việt Nam có thể thay đổi
    static let defaultDiscountRate = 0.0
}
```

*Giải pháp: Để người dùng cấu hình trong Settings.*

---

## 6. Phân Tích Rủi Ro

| Rủi Ro | Khả Năng Xảy Ra | Mức Độ Ảnh Hưởng | Biện Pháp |
|--------|----------------|-------------------|-----------|
| Mất dữ liệu do xóa nhầm | Cao | Nghiêm trọng | Thêm dialog xác nhận |
| SyncManager fake gây nhầm lẫn | Đã xảy ra | Cao | Vô hiệu hóa hoặc implement thật |
| Dữ liệu hóa đơn không chính xác do thiếu validation | Trung bình | Cao | Bổ sung validation |
| API ngoài ngừng hoạt động | Thấp | Trung bình | Đã có fallback |
| Hiệu năng kém với >1000 hóa đơn | Trung bình | Trung bình | Implement phân trang |
| Lỗ hổng bảo mật dữ liệu local | Thấp | Cao | Xem xét mã hóa SQLite |

---

## 7. Đề Xuất Cải Tiến

### Ưu Tiên Cao (Cần làm trước)

1. **Thêm InvoiceItem entity** — Lưu từng dòng sản phẩm/dịch vụ
2. **Implement xuất PDF** — Sử dụng `PDFKit` của Apple
3. **Sửa SyncManager** — Hoặc implement thật hoặc ẩn đi khỏi UI
4. **Thêm Unit Tests** — Tối thiểu cho Models và Services
5. **Hoàn thiện validation** — Email, MST, số tiền

### Ưu Tiên Trung Bình

6. **Thêm Undo/Redo** — Dùng `NSUndoManager` của CoreData
7. **Implement Export Data** — Xuất JSON/CSV thực sự
8. **Thêm dialog xác nhận xóa** — Bảo vệ dữ liệu
9. **Phân trang thực sự** — `NSFetchedResultsController`
10. **Báo cáo doanh thu** — Biểu đồ theo tháng/quý/năm

### Ưu Tiên Thấp

11. **Cấu hình VAT động** — Người dùng tự đặt tỷ lệ
12. **iCloud sync** — Sử dụng CoreData + CloudKit
13. **Xuất Excel/CSV** — Cho kế toán
14. **Notifications** — Nhắc nhở hóa đơn sắp quá hạn

---

## 8. Kết Luận

### Điểm Mạnh Tổng Thể

Muoi B2B Invoice Manager là một dự án **chất lượng tốt** cho mức độ 1.0.0, thể hiện:
- Kiến trúc code sạch, phân tầng rõ ràng
- Áp dụng đúng các nguyên lý OOP và design patterns
- Giao diện native macOS hiện đại với SwiftUI
- Tính năng VietQR độc đáo phù hợp thị trường Việt Nam
- Hiệu năng tốt với dữ liệu vừa (dưới 1,000 bản ghi)

### Điểm Yếu Cốt Lõi

Dự án cần cải thiện nghiêm túc ở:
- Thiếu hoàn toàn automated tests
- SyncManager fake gây hiểu nhầm người dùng
- Không lưu line items của hóa đơn (hạn chế lớn về nghiệp vụ)
- Chưa có tính năng in/xuất PDF

### Điểm Số Tổng Hợp

| Tiêu Chí | Điểm | Tỷ Trọng | Điểm Quy Đổi |
|---------|------|---------|-------------|
| Chức năng cốt lõi | 7.5/10 | 30% | 2.25 |
| Chất lượng code | 8.0/10 | 25% | 2.00 |
| Giao diện / UX | 8.5/10 | 20% | 1.70 |
| Kiểm thử | 2.0/10 | 15% | 0.30 |
| Tài liệu | 7.0/10 | 10% | 0.70 |
| **TỔNG** | | **100%** | **6.95 / 10** |

> **Nhận xét:** Dự án đạt mức **Khá (6.95/10)**. Tiềm năng tốt, cần bổ sung kiểm thử tự động và hoàn thiện các tính năng còn dở để đạt mức production-ready.

---

*Báo cáo này được lập dựa trên phân tích mã nguồn và kiểm thử thủ công. Để có đánh giá toàn diện hơn, cần bổ sung automated testing suite.*

---
**Hết báo cáo**
