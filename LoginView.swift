import SwiftUI
import DescopeKit

struct LoginView: View {
    @StateObject private var authService = AuthService.shared
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Image("hitcraft-logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 80)
                        .padding(.bottom, 40)
                    
                    if authService.isAuthenticated {
                        NavigationLink(destination: HomeView(), isActive: .constant(true)) {
                            EmptyView()
                        }
                    } else {
                        Button(action: {
                            Task {
                                await handleLogin()
                            }
                        }) {
                            HStack {
                                Image(systemName: "g.circle.fill")
                                    .foregroundColor(.white)
                                Text(isLoading ? "Signing in..." : "Sign in with Google")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                            .opacity(isLoading ? 0.7 : 1)
                        }
                        .disabled(isLoading)
                        .padding(.horizontal, 40)
                        
                        Button(action: {
                            if let url = URL(string: "https://hitcraft.ai/sign-up") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Text("Don't have an account? ")
                                .foregroundColor(.gray) +
                            Text("Sign up")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .alert("Authentication Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func handleLogin() async {
        isLoading = true
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            isLoading = false
            errorMessage = "Could not initialize login flow"
            showError = true
            return
        }
        
        do {
            try await authService.loginWithGoogle(from: rootViewController)
        } catch {
            errorMessage = "Authentication failed: \(error.localizedDescription)"
            showError = true
        }
        
        isLoading = false
    }
}
