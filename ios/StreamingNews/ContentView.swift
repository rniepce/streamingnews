import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ReleaseModel()
    
    var body: some View {
        NavigationStack {
            List {
                if viewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView("Carregando novidades...")
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                } else if viewModel.releases.isEmpty {
                    HStack {
                        Spacer()
                        Text("Nenhuma novidade encontrada para hoje.")
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(viewModel.releases) { item in
                        ReleaseRow(item: item)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Lançamentos \(viewModel.date)")
            .refreshable {
                viewModel.fetchReleases()
            }
            .onAppear {
                viewModel.fetchReleases()
            }
        }
    }
}

// MARK: - Release Row

struct ReleaseRow: View {
    let item: ReleaseItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Título
            Text(item.title)
                .font(.headline)
            
            // Serviços
            HStack {
                Image(systemName: "tv")
                    .foregroundStyle(.tint)
                Text(item.services)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            // Notas de críticos e público
            if item.critic_score != nil || item.user_rating != nil {
                HStack(spacing: 16) {
                    if let critic = item.critic_score {
                        HStack(spacing: 4) {
                            Text("🍅")
                            Text("\(critic)")
                                .font(.subheadline.bold())
                                .foregroundStyle(scoreColor(critic))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .glassEffect(.regular.interactive, in: .capsule)
                    }
                    if let user = item.user_rating {
                        HStack(spacing: 4) {
                            Text("⭐")
                            Text("\(user)")
                                .font(.subheadline.bold())
                                .foregroundStyle(scoreColor(user))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .glassEffect(.regular.interactive, in: .capsule)
                    }
                }
            }
            
            // Link IMDB
            if let url = URL(string: item.imdb_link), !item.imdb_link.isEmpty {
                Link(destination: url) {
                    Label("Ficha no IMDB", systemImage: "link")
                        .font(.subheadline)
                }
                .buttonStyle(.glass)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func scoreColor(_ score: Int) -> Color {
        if score >= 60 { return .green }
        if score >= 40 { return .yellow }
        return .red
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
