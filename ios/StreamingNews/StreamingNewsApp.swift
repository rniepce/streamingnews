import SwiftUI

@main
struct StreamingNewsApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .tabItem {
                        Label("Novidades", systemImage: "sparkles.tv")
                    }
                
                WishlistView()
                    .tabItem {
                        Label("Wishlist", systemImage: "heart.fill")
                    }
            }
            .tint(.red)
        }
    }
}
