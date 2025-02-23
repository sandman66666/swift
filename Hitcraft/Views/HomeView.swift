import SwiftUI

struct HomeView: View {
    @StateObject private var authService = Services.shared.auth
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    
    var body: some View {
        VStack {
            Text("Welcome to Home!")
                .font(.title)
            
            Button("Logout") {
                Task {  // Wrap async call in Task
                    await authService.logout()
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
