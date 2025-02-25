import SwiftUI

struct ProductionsView: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    
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
                    .font(HitCraftFonts.header())
                    .foregroundColor(HitCraftColors.text)
                Spacer()
            }
            .frame(height: 44)
            .padding(.horizontal, 20)
            .background(HitCraftColors.headerFooterBackground)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Text("Your Recent Productions")
                        .font(HitCraftFonts.subheader())
                        .foregroundColor(HitCraftColors.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                        .padding(.bottom, 16)
                    
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
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .background(HitCraftColors.background)
        }
        .background(HitCraftColors.background)
        .animation(.easeInOut(duration: 0.3), value: themeManager.currentTheme)
    }
}

struct ProductionTrackCard: View {
    let track: Track
    @State private var isPlaying = false
    @ObservedObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image Container with Play Button Overlay
            ZStack {
                if let imageUrl = track.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        Rectangle()
                            .fill(HitCraftColors.secondaryText.opacity(0.3))
                    }
                    .aspectRatio(1, contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    Rectangle()
                        .fill(HitCraftColors.secondaryText.opacity(0.3))
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
                        .fill(Color.white)
                        .frame(width: 44, height: 44)
                        .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
                        .overlay(
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .foregroundColor(.black)
                                .font(.system(size: 20))
                        )
                }
                .hitCraftStyle()
            }
            
            // Track Info
            VStack(alignment: .leading, spacing: 4) {
                Text(track.title)
                    .font(HitCraftFonts.subheader())
                    .foregroundColor(HitCraftColors.text)
                
                HStack(spacing: 4) {
                    Text(track.artist)
                        .font(HitCraftFonts.caption())
                        .foregroundColor(HitCraftColors.secondaryText)
                    
                    if track.verified {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(HitCraftColors.accent)
                            .font(.system(size: 10))
                    }
                }
                
                // Select Button with Gradient
                Button(action: {}) {
                    Text("SELECT")
                        .font(HitCraftFonts.caption())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(HitCraftColors.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: HitCraftLayout.buttonCornerRadius))
                }
                .padding(.top, 4)
                .hitCraftStyle()
            }
        }
        .padding(8)
        .background(HitCraftColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(themeManager.currentTheme == .dark ? 0.3 : 0.05), radius: 3, x: 0, y: 2)
    }
}

#Preview {
    ProductionsView()
}
