import UIKit
import SwiftUI

// MARK: - Scene Delegate example (not to be compiled directly)
/*
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let contentView = HitcraftContentView()
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(rootView: contentView)
        self.window = window
        window.makeKeyAndVisible()
        
        // Handle deep links if present on app launch
        if let url = connectionOptions.urlContexts.first?.url {
            handleDeepLink(url: url)
        }
    }
    
    // Handle OAuth callbacks via deep links
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        handleDeepLink(url: url)
    }
    
    private func handleDeepLink(url: URL) {
        // Check if it's an OAuth callback
        if url.absoluteString.starts(with: "hitcraft://oauth-callback") {
            // Handle the OAuth callback
            Task {
                do {
                    try await AuthService.shared.handleOAuthCallback(url: url)
                } catch {
                    print("OAuth callback handling failed: \(error)")
                    // Show error to user
                }
            }
        }
    }
}
*/

// MARK: - Example content view
struct HitcraftContentView: View {
    @ObservedObject private var authService = AuthService.shared
    
    var body: some View {
        Group {
            if authService.isLoading {
                ProgressView("Loading...")
            } else if authService.isAuthenticated {
                // User is logged in
                VStack {
                    Text("Welcome \(authService.currentUser?.displayName ?? "User")!")
                    Button("Logout") {
                        Task {
                            try? await authService.logout()
                        }
                    }
                }
            } else {
                // Login screen
                VStack {
                    Text("Please log in")
                    Button("Login with Google") {
                        Task {
                            do {
                                // Need to get the current UIViewController to present the OAuth flow
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let rootVC = windowScene.windows.first?.rootViewController {
                                    try await authService.loginWithGoogle(from: rootVC)
                                }
                            } catch {
                                print("Login failed: \(error)")
                            }
                        }
                    }
                }
            }
        }
    }
}
