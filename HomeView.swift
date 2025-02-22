import SwiftUI
import DescopeKit

struct HomeView: View {
    @StateObject private var authService = AuthService.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var showingLogoutError = false
    @State private var logoutErrorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if !authService.isAuthenticated {
                    NavigationLink(destination: LoginView()) {
                        Text("Go to Login")
                    }
                } else {
                    Text("Welcome to Hitcraft!")
                        .font(.title)
                    
                    if let user = authService.currentUser {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("User Info:")
                                .font(.headline)
                            Text("Email: \(user.email)")
                            if let name = user.name {
                                Text("Name: \(name)")
                            }
                            Text("ID: \(user.id)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        Task {
                            do {
                                try await authService.logout()
                                DispatchQueue.main.async {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            } catch {
                                logoutErrorMessage = error.localizedDescription
                                showingLogoutError = true
                            }
                        }
                    }) {
                        Text("Sign Out")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
            .navigationTitle("Hitcraft")
            .navigationBarBackButtonHidden(true)
            .alert("Logout Failed", isPresented: $showingLogoutError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(logoutErrorMessage)
            }
        }
    }
}
