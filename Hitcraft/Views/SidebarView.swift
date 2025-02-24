import SwiftUI

struct SidebarView: View {
    @Binding var isOpen: Bool
    @Binding var selectedArtist: ArtistProfile
    @State private var searchText = ""
    
    let artists = ArtistProfile.sampleArtists
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(HitCraftColors.secondaryText)
                        .padding(.leading, 18)
                    
                    TextField("Search musicians...", text: $searchText)
                        .font(HitCraftFonts.poppins(16, weight: .light))
                        .padding(.vertical, 13)
                }
                .background(HitCraftColors.background)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(HitCraftColors.border, lineWidth: 1)
                )
                .padding(.horizontal, 20)
                .padding(.top, 25)
                
                Divider()
                    .padding(.top, 25)
                    .padding(.bottom, 32)
                
                // Recommended Artists Section
                Text("Recommended Musicians")
                    .font(HitCraftFonts.poppins(11, weight: .light))
                    .foregroundColor(.black)
                    .padding(.leading, 32)
                    .padding(.bottom, 32)
                
                VStack(spacing: 8) {
                    ForEach(artists) { artist in
                        Button(action: {
                            selectedArtist = artist
                            isOpen = false
                        }) {
                            HStack(spacing: 17) {
                                // Artist Image
                                AsyncImage(url: URL(string: artist.imageUrl ?? "")) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Color.gray.opacity(0.3)
                                }
                                .frame(width: 27, height: 27)
                                .clipShape(Circle())
                                
                                // Text stack with exact specifications
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(artist.name)
                                        .font(HitCraftFonts.poppins(13, weight: .semibold))
                                        .foregroundColor(.black)
                                        .lineLimit(1)
                                    
                                    Text(artist.role?.primary ?? "Artist")
                                        .font(HitCraftFonts.poppins(13, weight: .light))
                                        .foregroundColor(.black)
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .frame(height: 58)
                            .background(
                                RoundedRectangle(cornerRadius: 23)
                                    .fill(selectedArtist.id == artist.id ? Color(hex: "E3E9F7").opacity(0.7) : Color.clear)
                            )
                            .padding(.horizontal, 20)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.top, 0)
                
                Spacer()
            }
            .padding(.top, 40)
        }
    }
}

#Preview {
    SidebarView(
        isOpen: .constant(true),
        selectedArtist: .constant(ArtistProfile.sample)
    )
}
