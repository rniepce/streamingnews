import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ReleaseModel()
    
    private var relativeDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: viewModel.date) else { return viewModel.date }
        if Calendar.current.isDateInToday(date) { return "Hoje" }
        if Calendar.current.isDateInYesterday(date) { return "Ontem" }
        return viewModel.date
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: viewModel.date) else { return viewModel.date }
        let display = DateFormatter()
        display.dateStyle = .long
        display.locale = Locale(identifier: "pt_BR")
        return display.string(from: date)
    }
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
            .navigationTitle(relativeDate)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text(relativeDate)
                            .font(.headline)
                        if relativeDate != viewModel.date {
                            Text(formattedDate)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
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
        HStack(alignment: .top, spacing: 12) {
            // Poster
            if let posterURL = item.poster_url, !posterURL.isEmpty, let url = URL(string: posterURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 90)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 60, height: 90)
                        .overlay(
                            Image(systemName: "film")
                                .foregroundStyle(.secondary)
                        )
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                // Título
                Text(item.title)
                    .font(.headline)
            
            // Serviços
            HStack(spacing: 6) {
                ForEach(item.services.components(separatedBy: ", "), id: \.self) { service in
                    serviceBadge(for: service)
                }
            }
            
            // Notas de críticos e público
            if item.critic_score != nil || item.user_rating != nil {
                HStack(spacing: 16) {
                    if let critic = item.critic_score {
                        scoreBadge(emoji: "🍅", value: "\(critic)", color: scoreColor(critic))
                    }
                    if let user = item.user_rating {
                        scoreBadge(emoji: "⭐", value: String(format: "%.1f", user), color: scoreColor(user))
                    }
                }
            }
            
            // Link IMDB
            if let url = URL(string: item.imdb_link), !item.imdb_link.isEmpty {
                Link(destination: url) {
                    Label("Ficha no IMDB", systemImage: "link")
                        .font(.subheadline)
                }
                .modifier(GlassButtonModifier())
            }
            }
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private func scoreBadge(emoji: String, value: String, color: Color) -> some View {
        let badge = HStack(spacing: 4) {
            Text(emoji)
            Text(value)
                .font(.subheadline.bold())
                .foregroundStyle(color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        
        if #available(iOS 26, *) {
            badge.glassEffect(.regular.interactive(), in: .capsule)
        } else {
            badge
                .background(.ultraThinMaterial, in: Capsule())
        }
    }
    
    private func scoreColor(_ score: some Comparable & Numeric) -> Color {
        if let intScore = score as? Int {
            if intScore >= 60 { return .green }
            if intScore >= 40 { return .yellow }
        } else if let doubleScore = score as? Double {
            if doubleScore >= 6.0 { return .green }
            if doubleScore >= 4.0 { return .yellow }
        }
        return .red
    }
    
    @ViewBuilder
    private func serviceBadge(for service: String) -> some View {
        let (logoURL, color) = serviceInfo(service)
        HStack(spacing: 5) {
            AsyncImage(url: URL(string: logoURL)) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } placeholder: {
                Image(systemName: "tv")
                    .font(.system(size: 10))
                    .foregroundStyle(.white)
            }
            Text(service)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(color, in: Capsule())
    }
    
    private func serviceInfo(_ service: String) -> (logoURL: String, color: Color) {
        let name = service.lowercased()
        if name.contains("netflix") {
            return ("https://logo.clearbit.com/netflix.com", Color.red)
        } else if name.contains("disney") {
            return ("https://logo.clearbit.com/disneyplus.com", Color(red: 0.07, green: 0.15, blue: 0.42))
        } else if name.contains("max") || name.contains("hbo") {
            return ("https://logo.clearbit.com/max.com", Color.purple)
        } else if name.contains("prime") {
            return ("https://logo.clearbit.com/primevideo.com", Color(red: 0.0, green: 0.66, blue: 0.88))
        } else if name.contains("apple tv+") {
            return ("https://logo.clearbit.com/tv.apple.com", Color(.darkGray))
        } else if name.contains("apple") {
            return ("https://logo.clearbit.com/apple.com", Color(.darkGray))
        } else if name.contains("mubi") {
            return ("https://logo.clearbit.com/mubi.com", Color.orange)
        }
        return ("", Color.secondary)
    }
}

// MARK: - Glass Button Modifier

struct GlassButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content.buttonStyle(.glass)
        } else {
            content.buttonStyle(.borderedProminent)
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
