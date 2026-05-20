import Foundation
import SwiftUI
import AppKit

// MARK: - NSVisualEffectView wrapper (Liquid Glass)
struct VisualEffectBlur: NSViewRepresentable {
    var material:     NSVisualEffectView.Material     = .hudWindow
    var blendingMode: NSVisualEffectView.BlendingMode = .withinWindow
    var state:        NSVisualEffectView.State        = .active

    func makeNSView(context: Context) -> NSVisualEffectView {
        let v = NSVisualEffectView()
        v.material     = material
        v.blendingMode = blendingMode
        v.state        = state
        return v
    }
    func updateNSView(_ v: NSVisualEffectView, context: Context) {
        v.material     = material
        v.blendingMode = blendingMode
        v.state        = state
    }
}

// MARK: - App Theme Colors
// Background/text/border tokens (appBg, appBg1-3, appText1-3, appBorder, appBorderH)
// are auto-generated from Assets.xcassets/Colors and respond to NSApp.appearance.
extension Color {
    // Pink primary (same in both modes)
    static let appIndigo = Color(red: 0.957, green: 0.447, blue: 0.714) // #F472B6 pink pastel
    static let appBlue   = Color(red: 0.965, green: 0.580, blue: 0.780) // #F694C7 light pink
    static let appViolet = Color(red: 0.910, green: 0.275, blue: 0.588) // #E84696 deep pink

    // Semantic status colors (same in both modes)
    static let appGreen  = Color(red: 0.086, green: 0.863, blue: 0.502)
    static let appOrange = Color(red: 0.976, green: 0.451, blue: 0.086)
    static let appRed    = Color(red: 0.937, green: 0.267, blue: 0.267)
    static let appYellow = Color(red: 0.917, green: 0.706, blue: 0.000)

    static func statusColor(_ status: String) -> Color {
        switch status {
        case "paid":      return .appGreen
        case "pending":   return .appOrange
        case "cancelled": return .appRed
        case "draft":     return .appText3
        default:          return .appText3
        }
    }
}

// MARK: - Reusable Components
struct StatusBadge: View {
    let status: String
    @EnvironmentObject var loc: LocalizationManager
    var body: some View {
        Text(loc.t(statusLabel))
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(Color.statusColor(status))
            .padding(.horizontal, 9).padding(.vertical, 3)
            .background(Color.statusColor(status).opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
    private var statusLabel: String {
        switch status {
        case "paid":        return "Đã thanh toán"
        case "pending":     return "Chờ xử lý"
        case "cancelled":   return "Đã hủy"
        case "draft":       return "Nháp"
        case "active":      return "Hoạt động"
        case "inactive":    return "Không HĐ"
        case "blacklisted": return "Cấm"
        default:            return status
        }
    }
}

// MARK: - Glass Card (adaptive Liquid Glass style)
struct GlassCardStyle: ViewModifier {
    @Environment(\.colorScheme) var scheme
    var radius:      CGFloat = 14
    var tint:        Color   = .white
    var tintOpacity: Double  = 0.04

    @State private var holoMouse:  CGPoint = .zero
    @State private var holoActive: Bool    = false

    func body(content: Content) -> some View {
        let isDark = scheme == .dark
        let overlayColors: [Color] = isDark
            ? [Color.white.opacity(0.16), Color.white.opacity(0.06)]
            : [Color.black.opacity(0.06), Color.black.opacity(0.02)]
        let shadowOpacity: Double = isDark ? 0.28 : 0.10
        let tintAdjusted: Color = isDark ? tint : Color.black
        let tintOp: Double = isDark ? tintOpacity : tintOpacity * 0.5

        return content
            .background(
                ZStack {
                    VisualEffectBlur(
                        material: isDark ? .hudWindow : .contentBackground,
                        blendingMode: .withinWindow
                    )
                    tintAdjusted.opacity(tintOp)
                }
                .clipShape(RoundedRectangle(cornerRadius: radius))
            )
            .clipShape(RoundedRectangle(cornerRadius: radius))
            // Holographic shimmer overlay (follows cursor)
            .overlay(
                GeometryReader { geo in
                    if holoActive {
                        RadialGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color(hue: 0.90, saturation: 0.75, brightness: 1).opacity(0.22), location: 0.00),
                                .init(color: Color(hue: 0.55, saturation: 0.75, brightness: 1).opacity(0.14), location: 0.40),
                                .init(color: Color(hue: 0.75, saturation: 0.75, brightness: 1).opacity(0.07), location: 0.70),
                                .init(color: .clear, location: 1.00)
                            ]),
                            center: UnitPoint(
                                x: geo.size.width  > 0 ? holoMouse.x / geo.size.width  : 0.5,
                                y: geo.size.height > 0 ? holoMouse.y / geo.size.height : 0.5
                            ),
                            startRadius: 0,
                            endRadius: max(geo.size.width, geo.size.height) * 0.65
                        )
                        .clipShape(RoundedRectangle(cornerRadius: radius))
                        .allowsHitTesting(false)
                    }
                }
            )
            // Border on top of shimmer
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .strokeBorder(
                        LinearGradient(
                            colors: overlayColors,
                            startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1)
            )
            .shadow(color: .black.opacity(shadowOpacity), radius: 12, x: 0, y: 6)
            .onContinuousHover { phase in
                switch phase {
                case .active(let loc):
                    holoMouse = loc
                    if !holoActive { withAnimation(.easeIn(duration: 0.15)) { holoActive = true } }
                case .ended:
                    withAnimation(.easeOut(duration: 0.25)) { holoActive = false }
                }
            }
    }
}

struct CardStyle: ViewModifier {
    var radius: CGFloat = 14
    func body(content: Content) -> some View {
        content.modifier(GlassCardStyle(radius: radius))
    }
}
extension View {
    func cardStyle(radius: CGFloat = 14) -> some View { modifier(CardStyle(radius: radius)) }
    func glassCard(radius: CGFloat = 14, tint: Color = .white, tintOpacity: Double = 0.04) -> some View {
        modifier(GlassCardStyle(radius: radius, tint: tint, tintOpacity: tintOpacity))
    }
}

// MARK: - Text Field Style (adaptive)
struct DarkTextFieldStyle: TextFieldStyle {
    @Environment(\.colorScheme) var scheme
    func _body(configuration: TextField<Self._Label>) -> some View {
        let isDark = scheme == .dark
        return configuration
            .padding(.horizontal, 11).padding(.vertical, 8)
            .background(
                ZStack {
                    VisualEffectBlur(
                        material: isDark ? .hudWindow : .contentBackground,
                        blendingMode: .withinWindow
                    )
                    (isDark ? Color.white : Color.black).opacity(isDark ? 0.04 : 0.03)
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
            )
            .foregroundColor(.appText1)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.appBorder, lineWidth: 1))
    }
}

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 18).padding(.vertical, 9)
            .background(
                LinearGradient(
                    colors: [Color.appIndigo, Color.appViolet],
                    startPoint: .topLeading, endPoint: .bottomTrailing)
                .opacity(configuration.isPressed ? 0.75 : 1)
            )
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 9))
            .shadow(color: Color.appIndigo.opacity(0.4), radius: 8, x: 0, y: 4)
            .fontWeight(.semibold)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.2), value: configuration.isPressed)
    }
}

struct GhostButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var scheme
    func makeBody(configuration: Configuration) -> some View {
        let isDark = scheme == .dark
        return configuration.label
            .padding(.horizontal, 18).padding(.vertical, 9)
            .background(
                ZStack {
                    VisualEffectBlur(
                        material: isDark ? .hudWindow : .contentBackground,
                        blendingMode: .withinWindow
                    )
                    (isDark ? Color.white : Color.black)
                        .opacity(configuration.isPressed ? 0.08 : 0.04)
                }
                .clipShape(RoundedRectangle(cornerRadius: 9))
            )
            .foregroundColor(.appText2)
            .clipShape(RoundedRectangle(cornerRadius: 9))
            .overlay(RoundedRectangle(cornerRadius: 9).strokeBorder(Color.appBorder, lineWidth: 1))
            .fontWeight(.medium)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.2), value: configuration.isPressed)
    }
}

// Glass divider
struct GlassDivider: View {
    @Environment(\.colorScheme) var scheme
    var body: some View {
        Rectangle()
            .fill(scheme == .dark ? Color.white.opacity(0.07) : Color.black.opacity(0.07))
            .frame(height: 1)
    }
}

// MARK: - Date Extensions
extension Date {
    func formattedString(pattern: String = "dd/MM/yyyy") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = pattern
        return formatter.string(from: self)
    }

    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components) ?? self
    }
}

// MARK: - Double Extensions
extension Double {
    func toCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = AppConstants.Finance.currencyCode
        return formatter.string(from: NSNumber(value: self)) ?? "0"
    }

    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

// MARK: - String Extensions
extension String {
    var isValidEmail: Bool {
        let emailRegex = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }

    var trimmed: String {
        self.trimmingCharacters(in: .whitespaces)
    }
}

// MARK: - NSColor Extensions
extension NSColor {
    convenience init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) {
        self.init(calibratedRed: red, green: green, blue: blue, alpha: alpha)
    }
}

// MARK: - View Extensions
extension View {
    func nsWindowFrame(minWidth: CGFloat? = nil, minHeight: CGFloat? = nil) -> some View {
        ZStack { self }
    }
}

// MARK: - NSNotification Extensions
extension NSNotification.Name {
    static let newInvoiceRequested = NSNotification.Name("NewInvoiceRequested")
    static let newClientRequested  = NSNotification.Name("NewClientRequested")
    static let dataChanged         = NSNotification.Name("DataChanged")
}
