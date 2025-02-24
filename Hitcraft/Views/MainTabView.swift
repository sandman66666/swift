import SwiftUI
import DescopeKit

final class TabSelection: ObservableObject {
    @Published var selectedTab = 0
    
    func switchTab(to tab: Int) {
        selectedTab = tab
    }
}

struct MainTabView: View {
    @StateObject private var tabSelection = TabSelection()
    @StateObject private var authService = Services.shared.auth
    @State private var selectedArtist = ArtistProfile.sample
    @State private var initialMessage: String?
    
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
                .environmentObject(tabSelection)
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    MainTabView()
}
