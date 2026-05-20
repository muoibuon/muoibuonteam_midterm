import SwiftUI

struct ListHeaderToolbar: View {
    let title: String
    let count: Int
    let primaryButtonTitle: String
    let action: () -> Void
    var searchText: Binding<String>? = nil
    @EnvironmentObject var loc: LocalizationManager

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.appText1)
                    Text("\(count) \(loc.t("mục"))")
                        .font(.system(size: 12))
                        .foregroundColor(.appText3)
                }

                Spacer()

                if let binding = searchText {
                    HStack(spacing: 7) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 12))
                            .foregroundColor(.appText3)
                        TextField(loc.t("Tìm kiếm..."), text: binding)
                            .textFieldStyle(.plain)
                            .font(.system(size: 13))
                            .foregroundColor(.appText1)
                            .frame(width: 180)
                        if !binding.wrappedValue.isEmpty {
                            Button { binding.wrappedValue = "" } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.appText3)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 10).padding(.vertical, 7)
                    .background(
                        ZStack {
                            VisualEffectBlur(material: .hudWindow, blendingMode: .withinWindow)
                            Color.white.opacity(0.04)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.white.opacity(0.1), lineWidth: 1))
                }

                Button(action: action) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                        Text(primaryButtonTitle)
                            .font(.system(size: 13, weight: .semibold))
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(.horizontal, 20).padding(.vertical, 16)

            GlassDivider()
        }
        .background(Color.clear)
    }
}
