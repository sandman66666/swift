import SwiftUI

struct ProductionsView: View {
    @State private var selectedGenre = "All Genres"
    @State private var selectedMood = "All Moods"
    
    let genres = ["All Genres", "Hip-Hop", "R&B", "Pop", "Electronic"]
    let moods = ["All Moods", "Energetic", "Chill", "Dark", "Happy"]
    
    var tracks: [Track] {
        // Sample tracks
        Track.sampleTracks
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Spacer()
                Text("PRODUCTIONS")
                    .font(HitCraftFonts.poppins(18, weight: .light))
                    .foregroundColor(.black)
                Spacer()
            }
            .frame(height: 44)
            .padding(.horizontal, 20)
            .background(Color.white)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Text("Your Recent Productions")
                        .font(HitCraftFonts.poppins(22, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                    
                    // Filter Menus
                    HStack(spacing: 12) {
                        // Genre Menu
                        Menu {
                            ForEach(genres, id: \.self) { genre in
                                Button(action: { selectedGenre = genre }) {
                                    if genre == selectedGenre {
                                        Label(genre, systemImage: "checkmark")
                                    } else {
                                        Text(genre)
                                    }
                                }
                            }
                        } label: {
                            FilterButton(title: selectedGenre)
                        }
                        
                        // Mood Menu
                        Menu {
                            ForEach(moods, id: \.self) { mood in
                                Button(action: { selectedMood = mood }) {
                                    if mood == selectedMood {
                                        Label(mood, systemImage: "checkmark")
                                    } else {
                                        Text(mood)
                                    }
                                }
                            }
                        } label: {
                            FilterButton(title: selectedMood)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Tracks Grid
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ],
                        spacing: 16
                    ) {
                        ForEach(tracks) { track in
                            ProductionTrackCard(track: track)
                        }
                    }
                    .padding(20)
                }
            }
        }
        .background(HitCraftColors.background)
    }
}

struct ProductionTrackCard: View {
    let track: Track
    @State private var isPlaying = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image Container with Play Button Overlay
            ZStack {
                if let imageUrl = track.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .aspectRatio(1, contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(1, contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            Text("\(track.imageNumber)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        )
                }
                
                // Play Button Overlay
                Button(action: {
                    isPlaying.toggle()
                }) {
                    Circle()
                        .fill(.white)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .foregroundColor(.black)
                                .font(.system(size: 20))
                        )
                }
            }
            
            // Track Info
            VStack(alignment: .leading, spacing: 4) {
                Text(track.title)
                    .font(HitCraftFonts.poppins(16, weight: .medium))
                
                HStack(spacing: 4) {
                    Text(track.artist)
                        .font(HitCraftFonts.poppins(14, weight: .regular))
                        .foregroundColor(.gray)
                    
                    if track.verified {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.pink)
                            .font(.system(size: 10))
                    }
                }
            }
        }
        .padding(8)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    ProductionsView()
}
