// ApiClient.swift
import Foundation

class ApiClient {
    static let shared = ApiClient()
    
    private let baseURL = "https://auth.hitcraft.ai/api"
    
    private init() {}
    
    // Generic request method
    func request<T: Decodable>(path: String, method: String = "GET", body: [String: Any]? = nil) async throws -> T {
        // Create URL
        guard let url = URL(string: baseURL + path) else {
            throw AuthError.invalidResponse
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add auth token
        if let token = AuthService.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add body if needed
        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        
        // Make request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }
        
        if httpResponse.statusCode == 401 {
            throw AuthError.unauthorized
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            throw AuthError.invalidResponse
        }
        
        // Decode response
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw AuthError.invalidResponse
        }
    }
    
    // Helper methods
    func get<T: Decodable>(path: String) async throws -> T {
        return try await request(path: path)
    }
    
    func post<T: Decodable>(path: String, body: [String: Any]) async throws -> T {
        return try await request(path: path, method: "POST", body: body)
    }
}
