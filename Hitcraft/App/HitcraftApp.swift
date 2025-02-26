import SwiftUI
import DescopeKit

@main
struct HitcraftApp: App {
    // Initialize auth service at app level
    @StateObject private var authService = Services.shared.auth
    // Initialize theme manager to be available globally
    @StateObject private var themeManager = ThemeManager.shared
    
    init() {
        // Initialize Descope with your project ID
        Descope.setup(projectId: "P2rIvbtGcXTcUfT68LGuVqPitlJd") { config in
            config.baseURL = "https://auth.dev.hitcraft.ai"
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainRootView()
                .environmentObject(authService)
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.currentTheme == .dark ? .dark : .light)
        }
    }
}

struct MainRootView: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var defaultArtist = ArtistProfile.sample
    @State private var selectedTab: MenuTab = .chat
    @State private var error: Error?
    @State private var showError = false
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                VStack(spacing: 0) {
                    // Main Content based on selected tab
                    mainContentView
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // Bottom Menu Bar
                    BottomMenuBar(selectedTab: $selectedTab, onStartNewChat: {
                        ChatService.shared.activeThreadId = nil
                        selectedTab = .chat
                    })
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToTab"))) { notification in
                    if let tab = notification.userInfo?["tab"] as? MenuTab {
                        selectedTab = tab
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: themeManager.currentTheme)
            } else {
                LoginView()
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(error?.localizedDescription ?? "An error occurred")
        }
    }
    
    @ViewBuilder
    private var mainContentView: some View {
        switch selectedTab {
        case .history:
            HistoryView()
        case .chat:
            ChatContentView(defaultArtist: defaultArtist)
        case .productions:
            ProductionsView()
        case .settings:
            SettingsView()
        }
    }
}
