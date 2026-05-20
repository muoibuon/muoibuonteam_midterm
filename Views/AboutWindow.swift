import SwiftUI

struct AboutWindow: View {
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 64, height: 64)

            Text(AppConstants.appName)
                .font(.title)
                .fontWeight(.bold)

            Text("Version \(AppConstants.appVersion)")
                .foregroundColor(.gray)

            Text("© 2024 Muoi\nAll rights reserved.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)

            Button("OK") {
                NSApplication.shared.mainWindow?.close()
            }
            .keyboardShortcut(.defaultAction)
        }
        .padding(40)
        .frame(width: 300, height: 250)
    }
}
