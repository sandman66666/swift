import SwiftUI

struct LoginView: View {
    @StateObject private var authService = Services.shared.auth
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .padding(.bottom, 20)
                    
                    Text("Welcome to Hitcraft")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Sign in to continue")
                        .font(.title3)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Button(action: {
                        isLoading = true
                        authService.startAuthFlow()
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 5)
                            }
                            
                            Text(isLoading ? "Signing in..." : "Sign In")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isLoading ? Color.blue.opacity(0.8) : Color.blue)
                        .cornerRadius(10)
                    }
                    .disabled(isLoading)
                    .padding(.horizontal, 30)
                    
                    VStack(spacing: 10) {
                        Text("Don't have an account?")
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            if let url = URL(string: "https://hitcraft.ai/sign-up") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Text("Create one here")
                                .foregroundColor(.blue)
                                .underline()
                        }
                    }
                    .font(.subheadline)
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .padding()
            }
        }
        .onChange(of: authService.isAuthenticated) { newValue in
            if !newValue {
                isLoading = false
            }
        }
    }
}
