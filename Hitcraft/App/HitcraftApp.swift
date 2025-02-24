import SwiftUI
import DescopeKit

@main
struct HitcraftApp: App {
    // Initialize auth service at app level
    @StateObject private var authService = Services.shared.auth
    @StateObject private var tabSelection = TabSelection()
    @State private var selectedArtist = ArtistProfile.sample
    
    init() {
        // Initialize Descope with your project ID
        Descope.setup(projectId: "P2rIvbtGcXTcUfT68LGuVqPitlJd") { config in
            config.baseURL = "https://auth.dev.hitcraft.ai"
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authService)
                .environmentObject(tabSelection)
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var tabSelection: TabSelection
    @State private var selectedArtist = ArtistProfile.sample
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                TabView(selection: $tabSelection.selectedTab) {
                    // Home Tab
                    HomeView(selectedArtist: $selectedArtist)
                        .environmentObject(authService)
                        .environmentObject(tabSelection)
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                        .tag(0)
                    
                    // Chat Tab
                    ChatView(selectedArtist: $selectedArtist)
                        .tabItem {
                            Image(systemName: "message")
                            Text("Chat")
                        }
                        .tag(1)
                    
                    // Library/Browse Tab
                    BrowseView(selectedArtist: $selectedArtist)
                        .tabItem {
                            Image(systemName: "music.note.list")
                            Text("Library")
                        }
                        .tag(2)
                    
                    // History Tab
                    ChatSummaryView(
                        isOpen: .constant(true),
                        selectedArtist: $selectedArtist
                    )
                    .tabItem {
                        Image(systemName: "clock")
                        Text("History")
                    }
                    .tag(3)
                }
                .tint(HitCraftColors.accent)
            } else {
                LoginView()
            }
        }
    }
}
