import SwiftUI

struct TrackCard: View {
    let track: Track
    @Binding var showingUploadDemo: Bool
    @State private var isHovering = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image Container with Play Button Overlay
            ZStack {
                // Track Image
                Image("\(track.imageNumber)")
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Play Button Overlay
                Circle()
                    .fill(.white)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "play.fill")
                            .foregroundColor(.black)
                            .font(.system(size: 20))
                    )
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
                
                // Select Button with Gradient
                Button(action: { showingUploadDemo = true }) {
                    Text("SELECT")
                        .font(HitCraftFonts.poppins(14, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(HitCraftColors.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .padding(.top, 4)
            }
        }
        .padding(8)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    TrackCard(
        track: Track.sampleTracks[0],
        showingUploadDemo: .constant(false)
    )
    .frame(width: 200)
    .padding()
}
