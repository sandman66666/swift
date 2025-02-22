import SwiftUI

@main
struct HitcraftApp: App {
    var body: some Scene {
        WindowGroup {
            MainContentView()
        }
    }
}

struct MainContentView: View {
    @StateObject private var authService = AuthService.shared
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                HomeView()
            } else {
                LoginView()
            }
        }
    }
}
