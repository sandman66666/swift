import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var tabSelection: TabSelection
    @Binding var selectedArtist: ArtistProfile
    @State private var showingSidebar = false
    @State private var messageText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom Navigation Bar
                HStack {
                    Button(action: { showingSidebar.toggle() }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 24))
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    // Artist Selector
                    Button(action: {}) {
                        HStack(spacing: 8) {
                            AsyncImage(url: URL(string: selectedArtist.imageUrl ?? "")) { image in
                                image.resizable()
                            } placeholder: {
                                Color.gray
                            }
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                            
                            Text(selectedArtist.name)
                                .font(HitCraftFonts.poppins(14, weight: .medium))
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(HitCraftColors.text)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.white)
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Welcome Section
                        VStack(spacing: 8) {
                            Text("Welcome to")
                                .font(HitCraftFonts.poppins(32, weight: .light))
                            Text("HITCRAFT")
                                .font(HitCraftFonts.poppins(32, weight: .bold))
                        }
                        .padding(.top, 24)
                        
                        // Quick Chat Input
                        HStack {
                            TextField("How can I help you make music today?", text: $messageText)
                                .font(HitCraftFonts.poppins(15, weight: .light))
                                .padding(.leading, 16)
                            
                            Button(action: {
                                if !messageText.isEmpty {
                                    tabSelection.switchTab(to: 1) // Switch to chat tab
                                }
                            }) {
                                Circle()
                                    .fill(HitCraftColors.primaryGradient)
                                    .frame(width: 37, height: 37)
                                    .overlay(
                                        Image(systemName: "arrow.up")
                                            .foregroundColor(.white)
                                            .rotationEffect(.degrees(45))
                                    )
                            }
                            .padding(.trailing, 6)
                        }
                        .padding(.vertical, 6)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(HitCraftColors.border, lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                        
                        // Action Cards
                        VStack(spacing: 12) {
                            ActionCard(
                                title: "Browse Music",
                                subtitle: "& Produce"
                            ) {
                                tabSelection.switchTab(to: 2) // Library tab
                            }
                            
                            ActionCard(
                                title: "Let's collaborate & make",
                                subtitle: "your next song together"
                            ) {
                                tabSelection.switchTab(to: 1) // Chat tab
                            }
                            
                            ActionCard(
                                title: "Get guidance, help and",
                                subtitle: "sounds for your project"
                            ) {
                                tabSelection.switchTab(to: 1) // Chat tab
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Recent Chats Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Your recent chats")
                                    .font(HitCraftFonts.poppins(14, weight: .medium))
                                Spacer()
                                Button("View all →") {
                                    tabSelection.switchTab(to: 3) // History tab
                                }
                                .foregroundColor(HitCraftColors.accent)
                            }
                            
                            RecentChatsGrid()
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .background(HitCraftColors.background)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSidebar) {
                SidebarView(isOpen: $showingSidebar, selectedArtist: $selectedArtist)
            }
        }
    }
}

#Preview {
    HomeView(selectedArtist: .constant(ArtistProfile.sample))
        .environmentObject(TabSelection())
        .environmentObject(Services.shared.auth)
}
