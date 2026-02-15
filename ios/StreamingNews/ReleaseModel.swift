import Foundation

struct ReleaseItem: Codable, Identifiable {
    var id: String { title } // Usando título como ID já que a API não garante ID único no JSON simplificado
    let title: String
    let services: String
    let imdb_link: String
}

struct DailyReleases: Codable {
    let date: String
    let items: [ReleaseItem]
}

class ReleaseModel: ObservableObject {
    @Published var releases: [ReleaseItem] = []
    @Published var date: String = ""
    @Published var isLoading = false
    
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
