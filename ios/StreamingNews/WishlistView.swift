import SwiftUI

struct WishlistView: View {
    @ObservedObject var wishlist = WishlistManager.shared
    
    private var wishlistMovies: [ReleaseItem] {
        wishlist.items.filter { $0.contentType.isMovie }
    }
    
    private var wishlistSeries: [ReleaseItem] {
        wishlist.items.filter { $0.contentType.isSeries }
    }
    
    private var wishlistOther: [ReleaseItem] {
        wishlist.items.filter { !$0.contentType.isMovie && !$0.contentType.isSeries }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if wishlist.items.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("Sua wishlist está vazia")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("Toque no ♡ ao lado de um lançamento para salvá-lo aqui.")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .listRowBackground(Color.clear)
                } else {
                    if !wishlistMovies.isEmpty {
                        Section {
                            ForEach(wishlistMovies) { item in
                                WishlistRow(item: item)
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    wishlist.remove(wishlistMovies[index])
                                }
                            }
                        } header: {
                            Label("Filmes", systemImage: "film")
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .textCase(nil)
                        }
                    }
                    
                    if !wishlistSeries.isEmpty {
                        Section {
                            ForEach(wishlistSeries) { item in
                                WishlistRow(item: item)
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    wishlist.remove(wishlistSeries[index])
                                }
                            }
                        } header: {
                            Label("Séries", systemImage: "tv")
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .textCase(nil)
                        }
                    }
                    
                    if !wishlistOther.isEmpty {
                        Section {
                            ForEach(wishlistOther) { item in
                                WishlistRow(item: item)
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    wishlist.remove(wishlistOther[index])
                                }
                            }
                        } header: {
                            Label("Outros", systemImage: "square.grid.2x2")
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .textCase(nil)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Wishlist")
            .toolbar {
                if !wishlist.items.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        EditButton()
                    }
                }
            }
        }
    }
}

// MARK: - Wishlist Row

struct WishlistRow: View {
    let item: ReleaseItem
    @ObservedObject var wishlist = WishlistManager.shared
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Poster
            if let posterURL = item.poster_url, !posterURL.isEmpty, let url = URL(string: posterURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 75)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 50, height: 75)
                        .overlay(
                            Image(systemName: "film")
                                .foregroundStyle(.secondary)
                        )
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(item.title)
                        .font(.headline)
                    
                    if !item.contentType.label.isEmpty {
                        Text(item.contentType.label)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(item.contentType.isMovie ? Color.indigo : Color.teal, in: Capsule())
                    }
                }
                
                // Serviços
                HStack(spacing: 4) {
                    Image(systemName: "play.tv")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(item.services)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // Scores
                HStack(spacing: 12) {
                    if let critic = item.critic_score {
                        HStack(spacing: 2) {
                            Text("🍅")
                                .font(.caption)
                            Text("\(critic)")
                                .font(.caption.bold())
                        }
                    }
                    if let user = item.user_rating {
                        HStack(spacing: 2) {
                            Text("⭐")
                                .font(.caption)
                            Text(String(format: "%.1f", user))
                                .font(.caption.bold())
                        }
                    }
                }
                
                // IMDB Link
                if let url = URL(string: item.imdb_link), !item.imdb_link.isEmpty {
                    Link(destination: url) {
                        Label("IMDB", systemImage: "link")
                            .font(.caption)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    WishlistView()
}
