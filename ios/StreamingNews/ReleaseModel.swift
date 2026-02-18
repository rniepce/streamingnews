import Foundation

enum ContentType: String {
    case movie = "movie"
    case tvSeries = "tv_series"
    case tvMovie = "tv_movie"
    case tvMiniSeries = "tv_miniseries"
    case tvSpecial = "tv_special"
    case shortFilm = "short_film"
    case unknown = "unknown"
    
    var isMovie: Bool {
        switch self {
        case .movie, .tvMovie, .shortFilm:
            return true
        default:
            return false
        }
    }
    
    var isSeries: Bool {
        switch self {
        case .tvSeries, .tvMiniSeries, .tvSpecial:
            return true
        default:
            return false
        }
    }
    
    var label: String {
        switch self {
        case .movie: return "Filme"
        case .tvSeries: return "Série"
        case .tvMovie: return "Telefilme"
        case .tvMiniSeries: return "Minissérie"
        case .tvSpecial: return "Especial"
        case .shortFilm: return "Curta"
        case .unknown: return ""
        }
    }
}

struct ReleaseItem: Codable, Identifiable {
    var id: String { title + (type ?? "unknown") }
    let title: String
    let type: String?
    let services: String
    let imdb_link: String
    let critic_score: Int?
    let user_rating: Double?
    let poster_url: String?
    
    var contentType: ContentType {
        ContentType(rawValue: type ?? "unknown") ?? .unknown
    }
}

struct DailyReleases: Codable {
    let date: String
    let items: [ReleaseItem]
}

class ReleaseModel: ObservableObject {
    @Published var releases: [ReleaseItem] = []
    @Published var date: String = ""
    @Published var isLoading = false
    
    var movies: [ReleaseItem] {
        releases.filter { $0.contentType.isMovie }
    }
    
    var series: [ReleaseItem] {
        releases.filter { $0.contentType.isSeries }
    }
    
    var other: [ReleaseItem] {
        releases.filter { !$0.contentType.isMovie && !$0.contentType.isSeries }
    }
    
    // Substitua pelo seu usuário/repo correto se mudar
    private let urlString = "https://raw.githubusercontent.com/rniepce/streamingnews/main/data/releases.json"
    
    func fetchReleases() {
        guard let url = URL(string: urlString) else { return }
        
        isLoading = true
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode(DailyReleases.self, from: data)
                    DispatchQueue.main.async {
                        self.releases = decodedData.items
                        self.date = decodedData.date
                    }
                } catch {
                    print("Erro ao decodificar JSON: \(error)")
                }
            }
        }.resume()
    }
}
