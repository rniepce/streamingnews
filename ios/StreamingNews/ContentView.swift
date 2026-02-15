import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ReleaseModel()
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.isLoading {
                    ProgressView("Carregando novidades...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowSeparator(.hidden)
                } else if viewModel.releases.isEmpty {
                    Text("Nenhuma novidade encontrada para hoje.")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowSeparator(.hidden)
                } else {
                    ForEach(viewModel.releases) { item in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(item.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack {
                                Image(systemName: "tv")
                                    .foregroundColor(.blue)
                                Text(item.services)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            if let url = URL(string: item.imdb_link), !item.imdb_link.isEmpty {
                                Link(destination: url) {
                                    HStack {
                                        Image(systemName: "link")
                                        Text("Ficha no IMDB")
                                    }
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                }
                                .padding(.top, 2)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
