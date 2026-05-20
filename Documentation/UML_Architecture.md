# Sơ Đồ UML Kiến Trúc — Muoi B2B Invoice Manager

> **Dự án**: Muoi — Ứng dụng quản lý hóa đơn B2B cho macOS  
> **Công nghệ**: Swift 5.9 · SwiftUI · CoreData · macOS 13+  
> **Tác giả**: Muoi · Phiên bản 1.0.0

---

## Mục Lục

1. [Sơ đồ Use Case](#1-sơ-đồ-use-case)
2. [Sơ đồ Thành phần (Component Diagram)](#2-sơ-đồ-thành-phần-component-diagram)
3. [Sơ đồ Lớp Tổng Quan (Class Diagram)](#3-sơ-đồ-lớp-tổng-quan-class-diagram)
4. [Sơ đồ Tuần Tự — Tạo Hóa Đơn (Sequence Diagram)](#4-sơ-đồ-tuần-tự--tạo-hóa-đơn)
5. [Sơ đồ Tuần Tự — Đồng Bộ Dữ Liệu](#5-sơ-đồ-tuần-tự--đồng-bộ-dữ-liệu)
6. [Sơ đồ Trạng Thái Hóa Đơn (State Diagram)](#6-sơ-đồ-trạng-thái-hóa-đơn)
7. [Sơ đồ Hoạt Động — Luồng Thanh Toán VietQR](#7-sơ-đồ-hoạt-động--luồng-thanh-toán-vietqr)

---

## 1. Sơ Đồ Use Case

> **Use Case Diagram** mô tả các chức năng hệ thống và ai được dùng chức năng đó.

```
┌─────────────────────────────────────────────────────────────────┐
│                    HỆ THỐNG MUOI B2B                            │
│                                                                 │
│   ┌──────────────────────────────────────────┐                  │
│   │           QUẢN LÝ HÓA ĐƠN                │                  │
│   │  (UC-01) Tạo hóa đơn mới                 │                  │
│   │  (UC-02) Xem danh sách hóa đơn           │                  │
│   │  (UC-03) Chỉnh sửa hóa đơn               │                  │
│   │  (UC-04) Xóa hóa đơn                     |                  │
│   │  (UC-05) Tìm kiếm / Lọc hóa đơn          │                  │
│   │  (UC-06) Ghi nhận thanh toán             │                  │
│   └──────────────────────────────────────────┘                  │
│                                                                 │
│   ┌──────────────────────────────────────────┐                  │
│   │           QUẢN LÝ KHÁCH HÀNG             │    [Người dùng]  │
│   │  (UC-07) Thêm khách hàng                 │◄───────○         │
│   │  (UC-08) Xem danh sách khách hàng        │        │         │
│   │  (UC-09) Chỉnh sửa thông tin KH          │        │         │
│   │  (UC-10) Xóa khách hàng                  │                  │
│   └──────────────────────────────────────────┘                  │
│                                                                 │
│   ┌──────────────────────────────────────────┐                  │
│   │           DASHBOARD & BÁO CÁO            │                  │
│   │  (UC-11) Xem tổng quan doanh thu         │                  │
│   │  (UC-12) Xem hóa đơn quá hạn             │                  │
│   │  (UC-13) Xem tỷ giá ngoại tệ             │                  │
│   └──────────────────────────────────────────┘                  │
│                                                                 │
│   ┌──────────────────────────────────────────┐                  │
│   │           THANH TOÁN                     │    [Hệ thống     │
│   │  (UC-14) Sinh mã QR VietQR               │◄───ngoài]        │
│   │  (UC-15) Xem tỷ giá hối đoái             │    (API)         │
│   └──────────────────────────────────────────┘                  │
│                                                                 │
│   ┌──────────────────────────────────────────┐                  │
│   │           CÀI ĐẶT                        │                  │
│   │  (UC-16) Đổi ngôn ngữ Việt/Anh           │                  │
│   │  (UC-17) Đổi giao diện sáng/tối          │                  │
│   │  (UC-18) Cấu hình ngân hàng VietQR       │                  │
│   │  (UC-19) Xuất dữ liệu (JSON)             │                  │
│   └──────────────────────────────────────────┘                  │
└─────────────────────────────────────────────────────────────────┘

Ghi chú:
  ○  = Actor (người tham gia)
  ◄── = quan hệ sử dụng (uses)
  (UC-xx) = mã use case
```

### Bảng Use Case Chi Tiết

| Mã | Tên Use Case | Diễn Viên | Mô Tả Ngắn |
|----|-------------|-----------|------------|
| UC-01 | Tạo hóa đơn mới | Người dùng | Nhập thông tin KH, sản phẩm, VAT, chiết khấu → lưu vào CoreData |
| UC-02 | Xem danh sách hóa đơn | Người dùng | Hiển thị bảng danh sách, hỗ trợ sắp xếp |
| UC-05 | Tìm kiếm / Lọc | Người dùng | Lọc theo trạng thái, ngày, khách hàng |
| UC-06 | Ghi nhận thanh toán | Người dùng | Cập nhật số tiền đã thanh toán, ngày thanh toán |
| UC-14 | Sinh mã QR VietQR | Người dùng + API | Gọi API img.vietqr.io tạo mã QR chuyển khoản |
| UC-15 | Tỷ giá hối đoái | Hệ thống + API | Tự động gọi API open.er-api.com mỗi khi mở app |

---

## 2. Sơ Đồ Thành Phần (Component Diagram)

> **Component Diagram** cho thấy cách các module lớn của hệ thống liên kết với nhau.

```
┌──────────────────────────────────────────────────────────────────────────┐
│                        ỨNG DỤNG MUOI B2B (macOS)                         │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐     │
│  │                        TẦNG GIAO DIỆN (Views Layer)             │     │
│  │                                                                 |     │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐   │     │
│  │  │  Dashboard   │  │ InvoiceViews │  │    ClientViews       │   │     │
│  │  │  View        │  │ (List+Detail │  │ (List+Table+Sheet)   │   │     │
│  │  │              │  │  +Sheet)     │  │                      │   │     │
│  │  └──────┬───────┘  └──────┬───────┘  └──────────┬───────────┘   │     │ 
│  │         │                 │                      │              │     │
│  │  ┌──────┴─────────────────┴──────────────────────┴───────────┐  │     │
│  │  │               MainWindow + MainSidebar                    │  │     │
│  │  └────────────────────────────────────────────────────────────┘ │     │
│  └──────────────────────────┬──────────────────────────────────────┘     │         
│                             │ sử dụng                                    │
│  ┌──────────────────────────▼──────────────────────────────────────┐     │
│  │                      TẦNG DỊCH VỤ (Services Layer)              │     │
│  │                                                                 |     │
│  │  ┌───────────────────┐  ┌──────────────┐  ┌──────────────────┐  │     │
│  │  │  CoreDataManager  │  │  APIService  │  │   SyncManager    │  │     │
│  │  │  (Singleton)      │  │  (Singleton) │  │   (Singleton)    │  │     │
│  │  │  - CRUD           │  │  - Tỷ giá    │  │   - Auto sync    │  │     │
│  │  │  - Fetch/Save     │  │  - VietQR    │  │   - Timer        │  │     │  
│  │  └────────┬──────────┘  │  - Countries │  └──────────────────┘  │     │
│  │           │             └──────┬───────┘                        │     │
│  └───────────┼────────────────────┼───────────────────────────────-┘     │
│              │ đọc/ghi            │ gọi API                              │
│  ┌───────────▼──────────┐  ┌──────▼────────────────────────────────┐     │
│  │   TẦNG DỮ LIỆU       │  │    DỊCH VỤ NGOÀI (External APIs)      │     │
│  │   (Models Layer)     │  │                                       │     │
│  │                      │  │  open.er-api.com  (Tỷ giá hối đoái)   │     │
│  │  ┌────────────────┐  │  │  img.vietqr.io    (Mã QR chuyển khoản)│     │
│  │  │   Invoice      │  │  │  restcountries.com (Danh sách quốc gia)│    │
│  │  │ (NSManagedObj) │  │  └────────────────────────────────────────┘    │
│  │  └────────────────┘  │                                                │
│  │  ┌────────────────┐  │  ┌────────────────────────────────────────┐    │
│  │  │    Client      │  │  │    TẦNG TIỆN ÍCH (Utilities)           │    │
│  │  │ (NSManagedObj) │  │  │  Constants · Extensions                │    │
│  │  └────────────────┘  │  │  Localization · ValidationHelper       │    │
│  │    [CoreData SQLite] │  └────────────────────────────────────────┘    │
│  └──────────────────────┘                                                │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Sơ Đồ Lớp Tổng Quan (Class Diagram)

> **Class Diagram** mô tả cấu trúc của từng lớp (class) và mối quan hệ giữa chúng.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         <<App Entry Point>>                             │
│                          B2BInvoiceApp                                  │
│─────────────────────────────────────────────────────────────────────────│
│  - appDelegate: AppDelegate                                             │
│  - localization: LocalizationManager                                    │
│─────────────────────────────────────────────────────────────────────────│
│  + body: Scene                                                          │
└──────────────────────────────┬──────────────────────────────────────────┘
                               │ tạo ra / sử dụng
           ┌───────────────────┼──────────────────────┐
           ▼                   ▼                      ▼
┌──────────────────┐  ┌─────────────────┐  ┌──────────────────────┐
│   AppDelegate    │  │  CoreDataManager│  │    APIService        │
│──────────────────│  │─────────────────│  │──────────────────────│
│ - aboutWindow    │  │ <<Singleton>>   │  │ <<Singleton>>        │
│ - prefsWindow    │  │─────────────────│  │──────────────────────│
│──────────────────│  │ + shared        │  │ + shared             │
│ + appDidFinish() │  │ + container     │  │ + rates: [String:Dbl]│
│ + newInvoice()   │  │ + context       │  │ + countries: [String]│
│ + newClient()    │  │─────────────────│  │──────────────────────│
│ + showAbout()    │  │ + save()        │  │ + fetchExchangeRates()│
│ + showPrefs()    │  │ + fetchRequest()│  │ + toVND()            │
│ + exportData()   │  │ + delete()      │  │ + fromVND()          │
└──────────────────┘  │ + createObject()│  │ + vietQRURL()        │
                      │ + count()       │  │ + fetchCountries()   │
                      │ + resetAllData()│  └──────────────────────┘
                      └────────┬────────┘
                               │ quản lý
               ┌───────────────┴───────────────┐
               ▼                               ▼
┌──────────────────────────┐   ┌──────────────────────────┐
│         Invoice          │   │          Client          │
│  <<NSManagedObject>>     │   │  <<NSManagedObject>>     │
│──────────────────────────│   │──────────────────────────│
│ + id: UUID               │   │ + id: UUID               │
│ + invoiceNumber: String  │   │ + name: String           │
│ + invoiceDate: Date      │   │ + email: String          │
│ + dueDate: Date          │   │ + phone: String          │
│ + status: String         │   │ + companyName: String    │
│ + subtotal: Double       │   │ + taxCode: String        │
│ + discountRate: Double   │   │ + totalInvoices: Int64   │
│ + vatRate: Double        │   │ + totalRevenue: Double   │
│ + totalAmount: Double    │   │ + outstandingBalance: Dbl│
│ + clientId: UUID         │   │ + creditLimit: Double    │
│ + paymentStatus: String  │   │ + status: String         │
│──────────────────────────│   │──────────────────────────│
│ + remainingAmount: Double│   │ + displayName: String    │
│ + isOverdue: Bool        │   │ + isActive: Bool         │
│ + statusDisplay: String  │   │ + creditAvailable: Double│
│ + fetchRequest()         │   │ + statusDisplay: String  │
└──────────────────────────┘   └──────────────────────────┘

               ┌───────────────────────────────────────┐
               ▼                                       ▼
┌──────────────────────────┐   ┌──────────────────────────────┐
│      SyncManager         │   │      LocalizationManager     │
│  <<Singleton>>           │   │  <<ObservableObject>>        │
│──────────────────────────│   │──────────────────────────────│
│ + isSyncing: Bool        │   │ + currentLanguage: String    │
│ + lastSyncDate: Date?    │   │──────────────────────────────│
│ + syncStatus: String     │   │ + localize(_ key:) -> String │
│ - syncTimer: Timer?      │   └──────────────────────────────┘
│──────────────────────────│
│ + startAutoSync()        │
│ + stopAutoSync()         │
│ + manualSync()           │
│ - performSync()          │
└──────────────────────────┘

──────── Ký hiệu ────────
<<Singleton>> = mẫu thiết kế, chỉ 1 đối tượng duy nhất
NSManagedObject = lớp cha trong CoreData (lưu dữ liệu vào SQLite)
──────────────────────────
```

---

## 4. Sơ Đồ Tuần Tự — Tạo Hóa Đơn

> **Sequence Diagram** mô tả thứ tự các thông điệp (message) được trao đổi khi thực hiện một hành động.

```
Người Dùng    NewInvoiceSheet    CoreDataManager    Database (SQLite)
    │                │                   │                  │
    │  Nhấn Cmd+N    │                   │                  │
    │────────────────►                   │                  │
    │                │                   │                  │
    │                │  createObject()   │                  │
    │                │──────────────────►│                  │
    │                │                   │  Tạo entity mới  │
    │                │                   │─────────────────►│
    │                │  trả về Invoice   │                  │
    │                │◄──────────────────│                  │
    │                │                   │                  │
    │  Nhập thông tin KH, số tiền, VAT   │                  │
    │────────────────►                   │                  │
    │                │                   │                  │
    │                │  Tính toán tự động│                  │
    │                │  (subtotal, VAT,  │                  │
    │                │   totalAmount)    │                  │
    │                │───────────────────┤                  │
    │                │                   │                  │
    │  Nhấn "Lưu"    │                   │                  │
    │────────────────►                   │                  │
    │                │  Validate()       │                  │
    │                │───────────────────┤                  │
    │                │  save()           │                  │
    │                │──────────────────►│                  │
    │                │                   │  context.save()  │
    │                │                   │─────────────────►│
    │                │                   │  Thành công      │
    │                │                   │◄─────────────────│
    │  Hóa đơn xuất hiện trong danh sách │                  │
    │◄───────────────│                   │                  │
    │                │                   │                  │
```

---

## 5. Sơ Đồ Tuần Tự — Đồng Bộ Dữ Liệu

```
AppDelegate    SyncManager    CoreDataManager    API Server
    │               │                │              │
    │  App khởi động│                │              │
    │───────────────►                │              │
    │               │ startAutoSync()│              │
    │               │────────────────►              │
    │               │ Tạo Timer (5 phút)            │
    │               │───────────────┤               │
    │               │               │               │
    │        [Sau 5 phút — Timer kích hoạt]         │
    │               │               │               │
    │               │  performSync()│               │
    │               │───────────────►               │
    │               │  isSyncing=true               │
    │               │───────────────┤               │
    │               │               │  POST /sync   │
    │               │               │──────────────►│
    │               │               │  200 OK       │
    │               │               │◄──────────────│
    │               │  isSyncing=false              │
    │               │  lastSyncDate = now           │
    │               │───────────────┤               │
    │               │               │               │
    │  App tắt      │               │               │
    │───────────────►               │               │
    │               │ stopAutoSync()│               │
    │               │────────────────►              │
    │               │ Timer bị hủy  │               │
    │               │               │  save()       │
    │               │               │──────────────►│
    │               │               │   SQLite      │
```

---

## 6. Sơ Đồ Trạng Thái Hóa Đơn (State Diagram)

> **State Diagram** mô tả vòng đời (life cycle) của một đối tượng qua các trạng thái.

```
                          ┌─────────────┐
                [Tạo mới] │             │
          ────────────────►   NHÁP      │
                          │  (draft)    │
                          └──────┬──────┘
                                 │ Gửi cho khách hàng
                                 ▼
                          ┌─────────────┐
                          │   CHỜ XỬ LÝ │◄──── Có thể hoàn tác
                          │  (pending)  │
                          └──────┬──────┘
                                 │
                    ┌────────────┼────────────┐
                    │            │            │
                    ▼            ▼            ▼
             ┌──────────┐  ┌─────────┐  ┌──────────┐
             │ ĐÃ THANH │  │ QUÁ HẠN │  │   HỦY    │
             │  TOÁN    │  │(overdue)│  │(cancelled│
             │  (paid)  │  │tự động  │  │          │
             └──────────┘  │phát hiện│  └──────────┘
                           └─────────┘
                                │
                                │ Khách thanh toán trễ
                                ▼
                          ┌──────────┐
                          │ ĐÃ THANH │
                          │  TOÁN    │
                          │  (paid)  │
                          └──────────┘

Điều kiện isOverdue: Date.now > dueDate AND paymentStatus != "paid"
                                         AND status != "cancelled"
```

---

## 7. Sơ Đồ Hoạt Động — Luồng Thanh Toán VietQR

> **Activity Diagram** mô tả luồng công việc (workflow) từng bước.

```
         [Người dùng mở InvoiceDetailView]
                        │
                        ▼
              Đã cấu hình ngân hàng?
              /                    \
           Có                       Không
           │                         │
           ▼                         ▼
  Hiển thị tab "VietQR"     Yêu cầu vào Settings
           │                 cấu hình bankId +
           ▼                 accountNo
  Gọi APIService.vietQRURL()
  (bankId, accountNo, amount, invoiceNumber)
           │
           ▼
  Tạo URL img.vietqr.io
  với query params (amount, addInfo, accountName)
           │
           ▼
  SwiftUI AsyncImage tải ảnh từ URL
           │
       ┌───┴───┐
    Thành      Lỗi mạng
    công         │
       │         ▼
       │   Hiển thị thông báo
       │   "Không thể tải QR"
       ▼
  Hiển thị mã QR PNG
  ➜ Khách hàng quét bằng app ngân hàng
           │
           ▼
  Người dùng nhấn "Ghi nhận thanh toán"
           │
           ▼
  Cập nhật paidAmount, paymentDate
  paymentStatus = "paid" (nếu đủ tiền)
           │
           ▼
  CoreDataManager.save() → SQLite
           │
           ▼
         [Kết thúc]
```

---

## Tóm Tắt Kiến Trúc

| Tầng | Module | Chức năng chính |
|------|--------|----------------|
| **Views** | 16 file Swift | Giao diện người dùng SwiftUI |
| **Services** | CoreDataManager | Lưu trữ dữ liệu local (SQLite) |
| **Services** | APIService | Kết nối 3 API ngoài |
| **Services** | SyncManager | Đồng bộ tự động mỗi 5 phút |
| **Models** | Invoice, Client | Thực thể dữ liệu CoreData |
| **Utilities** | 4 file Swift | Hằng số, tiện ích, đa ngôn ngữ |

**Mẫu kiến trúc**: MVVM (Model-View-ViewModel) biến thể cho macOS SwiftUI  
**Lưu trữ**: CoreData + SQLite (local, không cần internet)  
**Kết nối**: 3 API miễn phí, không cần API key
