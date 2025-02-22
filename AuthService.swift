import Foundation
import UIKit
import DescopeKit
import SwiftUI



class AuthService: ObservableObject {
    static let shared = AuthService()
    
    // Published properties for UI state tracking
    @Published var isAuthenticated = false
    @Published var isLoading = false
    
    private init() {
        // Check if we have a stored token
        checkAuthentication()
    }
    
    // Check if user is authenticated
    private func checkAuthentication() {
        // If we have a token, consider the user authenticated
        isAuthenticated = UserDefaults.standard.string(forKey: "authToken") != nil
    }
    
    // Login with Google
    func loginWithGoogle(from viewController: UIViewController) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let redirectURL = "hitcraft://oauth-callback"
        try await Descope.oauth.start(provider: .google, redirectURL: redirectURL, options: [])
    }
    
    // Handle OAuth callback
    func handleOAuthCallback(url: URL) async throws {
        isLoading = true
        defer { isLoading = false }
        
        // Extract code from URL
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            throw AuthError.invalidResponse
        }
        
        // Exchange code for tokens
        do {
            let response = try await Descope.oauth.webExchange(code: code)
            
            // Handle tokens without optional chaining
            // We need to use a different approach since the SDK tokens aren't optional
            // but their properties might be
            
            // Try to get session token as a string directly
            var sessionTokenString: String? = nil
            var refreshTokenString: String? = nil
            
            // Use do-catch to safely access properties
            do {
                // Access the session token's JWT if available
                let sessionToken = response.sessionToken
                sessionTokenString = sessionToken.jwt
            } catch {
                // Session token or its JWT might be nil, just continue
                print("Could not extract session token JWT")
            }
            
            do {
                // Access the refresh token's JWT if available
                let refreshToken = response.refreshToken
                refreshTokenString = refreshToken.jwt
            } catch {
                // Refresh token or its JWT might be nil, just continue
                print("Could not extract refresh token JWT")
            }
            
            // Save tokens if we were able to extract them
            if let sessionToken = sessionTokenString {
                UserDefaults.standard.set(sessionToken, forKey: "authToken")
            }
            
            if let refreshToken = refreshTokenString {
                UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
            }
            
            // Update authentication state
            await MainActor.run {
                self.isAuthenticated = true
            }
        } catch {
            throw AuthError.networkError
        }
    }
    
    // Get token for API requests
    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: "authToken")
    }
    
    // Logout
    func logout() {
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "refreshToken")
        isAuthenticated = false
    }
    
    // Refresh the token (if needed)
    func refreshTokenIfNeeded() async throws {
        guard let refreshToken = UserDefaults.standard.string(forKey: "refreshToken") else {
            throw AuthError.unauthorized
        }
        
        // Create the refresh request
        let url = URL(string: "https://auth.hitcraft.ai/v1/auth/refresh?dcs=t")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(refreshToken)", forHTTPHeaderField: "Authorization")
        
        // Send the request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check response status
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw AuthError.invalidResponse
        }
        
        // Parse response
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let sessionToken = json["sessionJwt"] as? String {
                    // Store the new token
                    UserDefaults.standard.set(sessionToken, forKey: "authToken")
                    
                    // Store new refresh token if available
                    if let refreshToken = json["refreshJwt"] as? String {
                        UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
                    }
                } else {
                    throw AuthError.invalidResponse
                }
            } else {
                throw AuthError.invalidResponse
            }
        } catch {
            throw AuthError.invalidResponse
        }
    }
}
