import Foundation

class SyncManager: ObservableObject {
    static let shared = SyncManager()
    
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var syncStatus: String = "Sẵn sàng"
    
    private var syncTimer: Timer?
    private let dataManager = CoreDataManager.shared
    
    private init() {
        loadLastSyncDate()
    }
    
    // MARK: - Start Auto Sync
    func startAutoSync() {
        guard AppConstants.Sync.isAutoSyncEnabled else { return }
        
        syncTimer = Timer.scheduledTimer(withTimeInterval: AppConstants.Sync.interval, repeats: true) { [weak self] _ in
            self?.performSync()
        }
    }
    
    // MARK: - Stop Auto Sync
    func stopAutoSync() {
        syncTimer?.invalidate()
        syncTimer = nil
    }
    
    // MARK: - Manual Sync
    func manualSync() {
        performSync()
    }
    
    // MARK: - Perform Sync
    private func performSync() {
        DispatchQueue.main.async {
            self.isSyncing = true
            self.syncStatus = "Đang đồng bộ..."
        }
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            // Simulate sync
            Thread.sleep(forTimeInterval: 1.0)
            
            DispatchQueue.main.async {
                self?.isSyncing = false
                self?.lastSyncDate = Date()
                self?.syncStatus = "Đã đồng bộ"
                
                // Save last sync date
                UserDefaults.standard.set(self?.lastSyncDate, forKey: "lastSyncDate")
            }
        }
    }
    
    // MARK: - Load Last Sync Date
    private func loadLastSyncDate() {
        lastSyncDate = UserDefaults.standard.object(forKey: "lastSyncDate") as? Date
    }
}
