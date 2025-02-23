import Foundation
import DescopeKit
import UIKit

// MARK: - Models
struct ArtistProfile: Codable, Identifiable {
    var id: String { email }
    let email: String
    let name: String
    var instructions: String?
    var phoneNumber: String?
    var birthdate: String?
    var imageUrl: String?
    var about: String?
    var biography: [String]?
    var role: ArtistRole?
    var livesIn: String?
    var musicalAchievements: [String]?
    var buisnessAchievements: [String]?
    var preferredGenres: [String]?
    var famousWorks: [String]?
    var socialMediaLinks: [String]?
}

struct ArtistRole: Codable {
    let primary: String
    var secondary: [String]?
}

struct ApiResponse<T: Codable>: Codable {
    let data: T
    let status: Int
    let message: String?
}

// MARK: - Services
@MainActor
class Services {
    static let shared = Services()
    
    let auth: AuthService
    let api: ApiClient
    
    private init() {
        auth = AuthService.shared
        api = ApiClient.shared
    }
}

// MARK: - ApiClient
@MainActor
class ApiClient {
    static let shared = ApiClient()
    
    private let baseURL = "https://api.dev.hitcraft.ai"
    
    private init() {}
    
    func get<T: Decodable>(path: String) async throws -> T {
        return try await request(path: path, method: "GET")
    }
    
    func post<T: Decodable>(path: String, body: [String: Any]? = nil) async throws -> T {
        return try await request(path: path, method: "POST", body: body)
    }
    
    private func request<T: Decodable>(path: String, method: String, body: [String: Any]? = nil) async throws -> T {
        let fullURL = baseURL + path
        print("🌐 Making request to: \(fullURL)")
        
        guard let url = URL(string: fullURL) else {
            throw NSError(domain: "ApiClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add auth token if available
        if let token = await AuthService.shared.getToken() {
            print("🔑 Using auth token: \(token.prefix(20))...")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("⚠️ No auth token available")
        }
        
        // Print all headers for debugging
        print("📝 Request headers:")
        request.allHTTPHeaders.forEach { print("   \($0): \($1)") }
        
        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            if let bodyData = request.httpBody,
               let bodyString = String(data: bodyData, encoding: .utf8) {
                print("📦 Request body: \(bodyString)")
            }
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NSError(domain: "ApiClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
            }
            
            print("📥 Response status code: \(httpResponse.statusCode)")
            
            // Print response body for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Response body: \(responseString)")
            }
            
            if httpResponse.statusCode == 401 {
                await AuthService.shared.logout()
                throw NSError(domain: "ApiClient", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NSError(domain: "ApiClient", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Request failed with status code \(httpResponse.statusCode)"])
            }
            
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                print("✅ Successfully decoded response")
                return decoded
            } catch {
                print("❌ Decoding error: \(error)")
                throw error
            }
        } catch {
            print("❌ Network error: \(error)")
            throw error
        }
    }
}

extension URLRequest {
    var allHTTPHeaders: [String: String] {
        allHTTPHeaderFields ?? [:]
    }
}

// MARK: - AuthService
@MainActor
class AuthService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    
    static let shared = AuthService()
    private let projectId = "P2rIvbtGcXTcUfT68LGuVqPitlJd"
    
    private init() {
        // Initialize Descope with the project ID
        Descope.setup(projectId: projectId)
        
        Task {
            isAuthenticated = await checkAuthentication()
        }
    }
    
    private func checkAuthentication() async -> Bool {
        return Descope.sessionManager.session != nil
    }
    
    func getToken() async -> String? {
        return Descope.sessionManager.session?.sessionToken.jwt
    }
    
    func startAuthFlow() {
        Task { @MainActor in
            let flowUrl = "https://auth.dev.hitcraft.ai/login/P2rIvbtGcXTcUfT68LGuVqPitlJd?flow=sign-in-v2"
            
            let flow = DescopeFlow(url: flowUrl)
            let flowVC = DescopeFlowViewController()
            flowVC.delegate = self
            flowVC.start(flow: flow)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(flowVC, animated: true)
            }
        }
    }
    
    func logout() async {
        await Descope.sessionManager.clearSession()
        isAuthenticated = false
    }
}

// MARK: - AuthService Delegate
extension AuthService: DescopeFlowViewControllerDelegate {
    nonisolated func flowViewControllerDidUpdateState(_ controller: DescopeFlowViewController, to state: DescopeFlowState, from previous: DescopeFlowState) {
        print("Flow state updated:", state)
    }
    
    nonisolated func flowViewControllerDidBecomeReady(_ controller: DescopeFlowViewController) {
        print("Flow is ready")
    }
    
    nonisolated func flowViewControllerShouldShowURL(_ controller: DescopeFlowViewController, url: URL, external: Bool) -> Bool {
        print("Should show URL:", url)
        return true
    }
    
    nonisolated func flowViewControllerDidCancel(_ controller: DescopeFlowViewController) {
        Task { @MainActor in
            controller.dismiss(animated: true)
        }
    }
    
    nonisolated func flowViewControllerDidFinish(_ controller: DescopeFlowViewController, response: AuthenticationResponse) {
        Task { @MainActor in
            let session = DescopeSession(from: response)
            Descope.sessionManager.manageSession(session)
            isAuthenticated = true
            controller.dismiss(animated: true)
        }
    }
    
    nonisolated func flowViewControllerDidFail(_ controller: DescopeFlowViewController, error: DescopeError) {
        Task { @MainActor in
            print("Auth Error:", error)
            controller.dismiss(animated: true)
        }
    }
}
