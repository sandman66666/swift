import SwiftUI
import DescopeKit

struct MainAppScreen: View {
    @StateObject private var authService = Services.shared.auth
    @State private var artists: [ArtistProfile] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading artists...")
                } else {
                    if !artists.isEmpty {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(artists) { artist in
                                    ArtistCard(artist: artist)
                                        .padding(.horizontal)
                                }
                            }
                            .padding(.vertical)
                        }
                    } else {
                        VStack(spacing: 20) {
                            Image(systemName: "music.note.list")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text(errorMessage ?? "No artists found")
                                .font(.headline)
                                .multilineTextAlignment(.center)
                            Button("Try Again") {
                                Task {
                                    await loadArtists()
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Artists")
            .navigationBarItems(
                trailing: Button(action: {
                    Task {
                        await authService.logout()
                    }
                }) {
                    Text("Logout")
                        .foregroundColor(.red)
                }
            )
            .task {
                await loadArtists()
            }
            .refreshable {
                await loadArtists()
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
                Button("Try Again") {
                    Task {
                        await loadArtists()
                    }
                }
            } message: {
                Text(errorMessage ?? "An error occurred")
            }
        }
    }
    
    private func loadArtists() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            print("🔄 Loading artists...")
            let token = await authService.getToken()
            if let token = token {
                print("✅ Token available: \(token.prefix(20))...")
            } else {
                print("⚠️ No token available")
            }
            
            // Try different API endpoints if needed
            let endpoints = [
                "/api/v1/artist",
                "/api/v1/artists",  // Try plural
                "/api/v2/artist"    // Try v2 if available
            ]
            
            var lastError: Error? = nil
            
            for endpoint in endpoints {
                do {
                    print("🎯 Trying endpoint: \(endpoint)")
                    let response: ApiResponse<[ArtistProfile]> = try await Services.shared.api.get(path: endpoint)
                    print("✅ Success! Got \(response.data.count) artists")
                    
                    await MainActor.run {
                        artists = response.data
                    }
                    return
                } catch {
                    print("❌ Failed with endpoint \(endpoint): \(error)")
                    lastError = error
                    // Continue to next endpoint
                }
            }
            
            // If we got here, all endpoints failed
            throw lastError ?? NSError(domain: "ApiClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "All API endpoints failed"])
            
        } catch {
            print("❌ Final error loading artists: \(error)")
            await MainActor.run {
                if let urlError = error as? URLError {
                    switch urlError.code {
                    case .notConnectedToInternet:
                        errorMessage = "No internet connection. Please check your connection and try again."
                    case .timedOut:
                        errorMessage = "Request timed out. Please try again."
                    default:
                        errorMessage = "Network error: \(urlError.localizedDescription)"
                    }
                } else {
                    errorMessage = "Server error: \(error.localizedDescription)\nPlease try again later."
                }
                showError = true
            }
        }
    }
    struct ArtistCard: View {
        let artist: ArtistProfile
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    // Profile image or placeholder
                    if let imageUrl = artist.imageUrl {
                        AsyncImage(url: URL(string: imageUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.gray
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 60, height: 60)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(artist.name)
                            .font(.headline)
                        Text(artist.email)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                
                if let about = artist.about {
                    Text(about)
                        .font(.body)
                        .lineLimit(2)
                }
                
                if let genres = artist.preferredGenres, !genres.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(genres, id: \.self) { genre in
                                Text(genre)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
}
