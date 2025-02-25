import SwiftUI

struct MusicianHeader: View {
    let artist: ArtistProfile
    let showSwitchOption: Bool
    let title: String
    let showTalentGPT: Bool
    @Binding var selectedArtist: ArtistProfile
    @State private var showingMusicianPicker = false
    
    var body: some View {
        HStack {
            Spacer()
            if showSwitchOption {
                Button(action: { showingMusicianPicker = true }) {
                    HStack(spacing: 8) {
                        AsyncImage(url: URL(string: artist.imageUrl ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                        
                        Text(artist.name)
                            .font(HitCraftFonts.subheader())
                            .foregroundColor(HitCraftColors.accent)
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14))
                            .foregroundColor(HitCraftColors.accent)
                    }
                }
                .sheet(isPresented: $showingMusicianPicker) {
                    MusicianPickerView(selectedArtist: $selectedArtist, isPresented: $showingMusicianPicker)
                }
                
                Text("•")
                    .foregroundColor(HitCraftColors.accent)
            } else {
                Text(artist.name)
                    .font(HitCraftFonts.subheader())
                    .foregroundColor(HitCraftColors.accent)
            }
            
            Text(showTalentGPT ? "TalentGPT™" : title)
                .font(HitCraftFonts.header())
                .foregroundColor(HitCraftColors.text)
            Spacer()
        }
        .frame(height: 44)
        .padding(.horizontal, 20)
        .background(Color.white)
    }
}

struct MusicianPickerView: View {
    @Binding var selectedArtist: ArtistProfile
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            List(ArtistProfile.sampleArtists) { artist in
                Button(action: {
                    selectedArtist = artist
                    isPresented = false
                }) {
                    HStack {
                        AsyncImage(url: URL(string: artist.imageUrl ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text(artist.name)
                                .font(HitCraftFonts.subheader())
                                .foregroundColor(HitCraftColors.text)
                            
                            if let role = artist.role?.primary {
                                Text(role)
                                    .font(HitCraftFonts.body())
                                    .foregroundColor(HitCraftColors.secondaryText)
                            }
                        }
                        
                        if artist.id == selectedArtist.id {
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundColor(HitCraftColors.accent)
                        }
                    }
                }
                .listRowSeparator(.hidden)
                .padding(.vertical, 4)
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Select Artist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
}
