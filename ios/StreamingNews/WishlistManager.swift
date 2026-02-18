import Foundation

class WishlistManager: ObservableObject {
    static let shared = WishlistManager()
    
    @Published var items: [ReleaseItem] = []
    
    private let key = "wishlist_items"
    
    private init() {
        load()
    }
    
    func isInWishlist(_ item: ReleaseItem) -> Bool {
        items.contains { $0.title == item.title && $0.type == item.type }
    }
    
    func toggle(_ item: ReleaseItem) {
        if isInWishlist(item) {
            remove(item)
        } else {
            add(item)
        }
    }
    
    func add(_ item: ReleaseItem) {
        guard !isInWishlist(item) else { return }
        items.append(item)
        save()
    }
    
    func remove(_ item: ReleaseItem) {
        items.removeAll { $0.title == item.title && $0.type == item.type }
        save()
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([ReleaseItem].self, from: data) else { return }
        items = decoded
    }
}
