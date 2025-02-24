import Foundation
import DescopeKit

@MainActor
final class ApiClient {
    static let shared = ApiClient()
    private let urlSession: URLSession
    private let timeoutInterval: TimeInterval = 30
    private let decoder: JSONDecoder
    
    private init() {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.timeoutIntervalForRequest = timeoutInterval
        config.timeoutIntervalForResource = timeoutInterval
        
        self.urlSession = URLSession(configuration: config)
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .useDefaultKeys
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    func get<T: Codable>(path: String) async throws -> T {
        return try await request(path: path, method: "GET")
    }
    
    func post<T: Codable>(path: String, body: [String: Any]? = nil) async throws -> T {
        return try await request(path: path, method: "POST", body: body)
    }
    
    private func request<T: Codable>(path: String, method: String, body: [String: Any]? = nil) async throws -> T {
        let fullURL = HCEnvironment.apiBaseURL + path
        print("🚀 Making request to: \(fullURL)")
        
        guard let url = URL(string: fullURL) else {
            throw ApiError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = timeoutInterval
        
        // Headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(HCEnvironment.webAppURL, forHTTPHeaderField: "Origin")
        
        // Get fresh session token
        guard let session = Descope.sessionManager.session else {
            print("⚠️ No active session found")
            throw ApiError.unauthorized
        }
        
        let token = session.sessionToken.jwt
        print("🔐 Using token: \(String(token.prefix(10)))...")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            print("📤 Request body: \(body)")
        }
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ApiError.networkError(NSError(domain: "", code: -1))
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("📡 Response: \(responseString)")
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
                        throw ApiError.serverError(code: httpResponse.statusCode, message: errorResponse.error)
                    }
                    
                    let decoded = try decoder.decode(T.self, from: data)
                    print("✅ Successfully decoded response")
                    return decoded
                } catch {
                    print("❌ Decoding error: \(error)")
                    throw ApiError.decodingError(error)
                }
            case 401:
                await AuthService.shared.logout()
                throw ApiError.unauthorized
            case 403:
                if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
                    throw ApiError.forbidden(errorResponse.error)
                }
                throw ApiError.forbidden(nil)
            case 503:
                throw ApiError.serverUnavailable
            default:
                if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
                    throw ApiError.serverError(code: httpResponse.statusCode, message: errorResponse.error)
                }
                throw ApiError.serverError(code: httpResponse.statusCode, message: nil)
            }
        } catch let error as ApiError {
            throw error
        } catch {
            throw ApiError.networkError(error)
        }
    }
}

// Error response type
struct ErrorResponse: Codable {
    let error: String
}
