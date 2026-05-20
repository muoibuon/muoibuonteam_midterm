import Foundation
import SwiftUI

final class LocalizationManager: ObservableObject {
    @Published var language: String {
        didSet { UserDefaults.standard.set(language, forKey: "appLanguage") }
    }

    init() {
        self.language = UserDefaults.standard.string(forKey: "appLanguage") ?? "vi"
    }

    func t(_ key: String) -> String {
        if language == "en" {
            return Self.viToEn[key] ?? key
        }
        return key
    }

    static let viToEn: [String: String] = [
        // Section titles
        "GIAO DIỆN": "APPEARANCE",
        "TÀI CHÍNH": "FINANCE",
        "ĐỒNG BỘ": "SYNC",
        "NGÂN HÀNG & VIETQR": "BANK & VIETQR",
        "THÔNG TIN HÓA ĐƠN": "INVOICE INFO",
        "KHÁCH HÀNG": "CLIENT",
        "GHI CHÚ": "NOTES",
        "THÔNG TIN DOANH NGHIỆP": "BUSINESS INFO",
        "LIÊN HỆ": "CONTACT",
        "ĐỊA CHỈ": "ADDRESS",
        "THƯƠNG MẠI": "COMMERCIAL",
        "THÔNG TIN CHUNG": "GENERAL INFO",
        "XEM TRƯỚC": "PREVIEW",
        "TỔNG CỘNG": "TOTAL",
        "QUÁ HẠN": "OVERDUE",
        "NGÔN NGỮ": "LANGUAGE",

        // Sidebar
        "Chính": "Main",
        "Hệ thống": "System",
        "Hóa đơn": "Invoices",
        "Khách hàng": "Clients",
        "Tùy chọn": "Settings",
        "Đang tải tỷ giá...": "Loading rates...",
        "Chưa có tỷ giá": "No rates",
        "Tỷ giá cập nhật": "Rates updated",

        // Appearance / language
        "Chế độ hiển thị": "Display mode",
        "Ngôn ngữ": "Language",
        "Tối": "Dark",
        "Sáng": "Light",
        "Tiếng Việt": "Vietnamese",
        "Tiếng Anh": "English",

        // Settings / finance
        "VAT mặc định": "Default VAT",
        "Chiết khấu mặc định": "Default discount",
        "Ngân hàng": "Bank",
        "Số tài khoản": "Account number",
        "Tên tài khoản": "Account name",
        "Xem trước QR": "QR preview",
        "Đồng bộ tự động": "Auto sync",
        "Làm mới": "Refresh",

        // Settings header
        "Cài đặt ứng dụng và tích hợp": "App settings and integrations",
        "Cài đặt": "Settings",

        // Dashboard
        "Tổng quan hoạt động kinh doanh": "Business activity overview",
        "Doanh thu": "Revenue",
        "HĐ": "Inv",
        "Chưa thu": "Outstanding",
        "Quá hạn": "Overdue",
        "Hóa đơn gần đây": "Recent invoices",
        "tổng": "total",
        "Chưa có hóa đơn nào": "No invoices yet",
        "Tỷ giá hôm nay": "Today's rates",
        "Không thể tải tỷ giá": "Cannot load rates",
        "Cập nhật": "Updated",

        // Status
        "Tất cả": "All",
        "Nháp": "Draft",
        "Chờ xử lý": "Pending",
        "Đã thanh toán": "Paid",
        "Đã hủy": "Cancelled",
        "Hoạt động": "Active",
        "Không HĐ": "Inactive",
        "Không hoạt động": "Inactive",
        "Cấm": "Blacklisted",
        "Tạm dừng": "Inactive",
        "Hủy": "Cancel",

        // List header
        "Tạo mới": "New",
        "mục": "items",
        "Tìm kiếm...": "Search...",

        // Invoice table
        "Số HĐ": "Inv No",
        "Ngày": "Date",
        "Tổng tiền": "Total",
        "Còn lại": "Balance",
        "Trạng thái": "Status",
        "Không tìm thấy hóa đơn": "No invoices found",
        "Nhấn \"Tạo mới\" để thêm hóa đơn đầu tiên": "Click \"New\" to add your first invoice",

        // Clients table
        "Công ty / Tên": "Company / Name",
        "Điện thoại": "Phone",
        "Hạn mức còn": "Credit left",
        "Không tìm thấy khách hàng": "No clients found",
        "Nhấn \"Tạo mới\" để thêm khách hàng đầu tiên": "Click \"New\" to add your first client",

        // Invoice detail
        "Xóa hóa đơn?": "Delete invoice?",
        "Xóa": "Delete",
        "Thao tác này không thể hoàn tác.": "This action cannot be undone.",
        "Phát hành": "Issued",
        "Đến hạn": "Due",
        "Mô tả": "Description",
        "Ngày HĐ": "Invoice date",
        "PT thanh toán": "Payment method",
        "Tên": "Name",
        "ĐT": "Phone",
        "ĐC": "Address",
        "Không có ghi chú": "No notes",
        "Tạm tính": "Subtotal",
        "Chiết khấu": "Discount",
        "Sau CK": "After discount",
        "Đánh dấu Đã thanh toán": "Mark as Paid",
        "Hủy hóa đơn": "Cancel invoice",
        "Xóa hóa đơn": "Delete invoice",
        "QR Chuyển khoản": "Transfer QR",
        "Không tải được QR": "Cannot load QR",
        "Chuyển khoản": "Bank transfer",
        "Tiền mặt": "Cash",
        "Thẻ tín dụng": "Credit card",

        // New invoice sheet
        "Lỗi": "Error",
        "Tạo Hóa Đơn Mới": "Create New Invoice",
        "Điền thông tin và nhấn Lưu": "Fill in info and click Save",
        "Số hóa đơn": "Invoice number",
        "Phương thức thanh toán": "Payment method",
        "Ngày phát hành": "Issue date",
        "Ngày đến hạn": "Due date",
        "Mô tả công việc": "Job description",
        "Mô tả dịch vụ hoặc sản phẩm...": "Describe service or product...",
        "Tên khách hàng": "Client name",
        "Chọn khách hàng": "Select client",
        "— Nhập thủ công —": "— Manual entry —",
        "Tên công ty hoặc cá nhân": "Company or individual name",
        "Tiền tệ": "Currency",
        "Tỷ giá quy đổi": "Exchange rate",
        "Thuế VAT": "VAT",
        "MST": "Tax ID",
        "VietQR thanh toán": "VietQR Payment",
        "Cài đặt tài khoản ngân hàng trong Tùy chọn để hiển thị QR thanh toán": "Configure bank account in Settings to display payment QR",
        "Không thể tải QR": "Cannot load QR",
        "Lưu hóa đơn": "Save invoice",
        "Vui lòng nhập số hóa đơn": "Please enter invoice number",
        "Vui lòng chọn hoặc nhập tên khách hàng": "Please select or enter client name",
        "Vui lòng nhập tạm tính > 0": "Please enter subtotal > 0",

        // New client sheet
        "TNHH": "LLC",
        "Cổ phần": "JSC",
        "Tư nhân": "Private",
        "Hợp danh": "Partnership",
        "Khác": "Other",
        "Thêm Khách Hàng Mới": "Add New Client",
        "Thông tin doanh nghiệp": "Business information",
        "Lưu khách hàng": "Save client",
        "Tên công ty": "Company name",
        "Loại hình": "Type",
        "Tên liên hệ": "Contact name",
        "Mã số thuế": "Tax code",
        "Ngành nghề": "Industry",
        "Địa chỉ": "Address",
        "Số nhà, đường, phường/xã": "Street, ward",
        "Thành phố": "City",
        "Quốc gia": "Country",
        "Hạn mức tín dụng (VND)": "Credit limit (VND)",
        "Kỳ thanh toán": "Payment terms",
        "ngày": "days",
        "Tìm quốc gia...": "Search country...",
        "Vui lòng nhập tên công ty hoặc tên liên hệ": "Please enter company or contact name",
        "Vui lòng nhập ít nhất email hoặc số điện thoại": "Please enter at least email or phone",
        "Công nghệ thông tin": "Information technology",
        "Thanh toan hoa don": "Invoice payment",
    ]
}
