<p align="center">
  <img width="121" height="121" alt="image" src="https://github.com/user-attachments/assets/7c4be3ed-4eff-42ee-ae05-6d107a0cd055" />


</p>

# Check this OUT ! Tải ngay .dmg trên web mà không cần clone repo !
<p align="center">
https://muoibuonmidterm.vercel.app

</p>


# Muoi — B2B Invoice Manager

Ứng dụng native macOS quản lý hóa đơn B2B: tạo hóa đơn, quản lý khách hàng, theo dõi doanh thu, xuất VietQR thanh toán. Giao diện SwiftUI với hỗ trợ sáng/tối và song ngữ Việt/Anh.

  ![Swift](https://img.shields.io/badge/Language-Swift%205.9-F05138?style=flat&logo=swift&logoColor=white)
  ![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-0070C9?style=flat&logo=apple&logoColor=white)                                                                                                        
  ![CoreData](https://img.shields.io/badge/Database-CoreData%20%2B%20SQLite-003B57?style=flat&logo=sqlite&logoColor=white)                                                                                
  ![macOS](https://img.shields.io/badge/Platform-macOS%2013%2B-000000?style=flat&logo=apple&logoColor=white)                                                                                              
  ![Xcode](https://img.shields.io/badge/IDE-Xcode%2015-147EFB?style=flat&logo=xcode&logoColor=white) ![VietQR](https://img.shields.io/badge/API-VietQR-E31837?style=flat&logo=qrcode&logoColor=white)   
  ![Architecture](https://img.shields.io/badge/Architecture-MVVM-6DB33F?style=flat&logo=diagram&logoColor=white)
  ![License](https://img.shields.io/badge/License-MIT-green?style=flat&logo=opensourceinitiative&logoColor=white)

## Tính năng
```
- Hóa đơn: tạo, chỉnh sửa, theo dõi thanh toán, cảnh báo quá hạn, VAT & chiết khấu tự động
- Khách hàng: CRUD, hạn mức tín dụng, thống kê doanh thu
- Dashboard: tổng quan doanh thu, công nợ, hóa đơn quá hạn, tỷ giá ngoại tệ
- VietQR: sinh mã QR chuyển khoản theo số hóa đơn
- Đa ngôn ngữ: Tiếng Việt / Tiếng Anh
- Giao diện: sáng/tối thích ứng, Liquid Glass
```

## Yêu cầu
```
- macOS 13.0+
- Xcode 15+
- Swift 5.9+
```
## Cấu trúc dự án

```
App/
  B2BApp.swift              @main + AppDelegate + menu bar
  Assets.xcassets           Màu thích ứng light/dark + icon
Models/
  Models.swift              Invoice, Client Core Data entities
Services/
  CoreDataManager.swift     Core Data stack, CRUD
  SyncManager.swift         Auto-sync
  APIService.swift          Tỷ giá, quốc gia, VietQR URL
Utilities/
  Constants.swift           AppConstants: cấu hình toàn app
  Extensions.swift          Màu, modifier glass, formatter
  Localization.swift        LocalizationManager (vi/en)
  ValidationHelper.swift    Validate email, phone, amount…
Views/
  MainWindow.swift          NavigationSplitView shell
  MainSidebar.swift         Sidebar menu
  DashboardView.swift       StatCard.swift
  InvoiceListView.swift     InvoiceTableView.swift
  InvoiceDetailView.swift   NewInvoiceSheet.swift
  ClientsListView.swift     ClientsTableView.swift
  NewClientSheet.swift
  SettingsView.swift        SettingsFormView.swift
  PreferencesWindow.swift   AboutWindow.swift
  ListHeaderToolbar.swift
```

## Build & Run

```
# Download .dmg trên website

# Hoặc mở trong Xcode
open B2BInvoiceApp.xcodeproj

# Hoặc build trực tiếp
xcodebuild -project B2BInvoiceApp.xcodeproj \
           -scheme B2BInvoiceApp \
           -configuration Release build
```

## License

MIT © Muoi
