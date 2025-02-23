import SwiftUI
import SwiftUI
import DescopeKit

struct MainContentView: View {
    @StateObject private var authService = Services.shared.auth
    
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
