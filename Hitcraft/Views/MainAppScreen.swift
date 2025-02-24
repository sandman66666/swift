import SwiftUI
import DescopeKit

struct MainAppScreen: View {
    @EnvironmentObject private var authService: AuthService
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
            artists = try await Services.shared.artistApi.list()
        } catch let error as ApiError {
            print("❌ Error loading artists: \(error)")
            errorMessage = error.errorDescription ?? "An unexpected error occurred"
            showError = true
        } catch {
            print("❌ Unexpected error loading artists: \(error)")
            errorMessage = "An unexpected error occurred. Please try again."
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
