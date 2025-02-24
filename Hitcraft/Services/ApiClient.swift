import Foundation

@MainActor
final class ApiClient {
    static let shared = ApiClient()
    private let urlSession: URLSession
    private let timeoutInterval: TimeInterval = 30
    
    private init() {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.httpAdditionalHeaders = [
            "Accept-Language": "en-US,en;q=0.9",
            "Accept-Encoding": "gzip, deflate, br"
        ]
        self.urlSession = URLSession(configuration: config)
    }
    
    func get<T: Decodable>(path: String) async throws -> T {
        return try await request(path: path, method: "GET")
    }
    
    func post<T: Decodable>(path: String, body: [String: Any]? = nil) async throws -> T {
        return try await request(path: path, method: "POST", body: body)
    }
    
    private func request<T: Decodable>(path: String, method: String, body: [String: Any]? = nil) async throws -> T {
        let fullURL = HCEnvironment.apiBaseURL + path
        print("🌐 Request to: \(fullURL)")
        
        guard let url = URL(string: fullURL) else {
            throw ApiClientError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = timeoutInterval
        
        // Basic headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // AWS ALB likes these headers
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")
        request.setValue(HCEnvironment.webAppURL, forHTTPHeaderField: "Referer")
        request.setValue("*/*", forHTTPHeaderField: "Accept")  // More permissive accept
        request.setValue("en-US,en;q=0.9", forHTTPHeaderField: "Accept-Language")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        
        // Host header (important for ALB routing)
        if let host = url.host {
            request.setValue(host, forHTTPHeaderField: "Host")
        }
        
        // CORS headers
        request.setValue(HCEnvironment.webAppURL, forHTTPHeaderField: "Origin")
        request.setValue("cors", forHTTPHeaderField: "Sec-Fetch-Mode")
        request.setValue("same-site", forHTTPHeaderField: "Sec-Fetch-Site")
        request.setValue("empty", forHTTPHeaderField: "Sec-Fetch-Dest")
        
        // Browser-like User-Agent
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        
        // Auth token
        if let token = await AuthService.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Print request details
        print("📝 Request headers:")
        request.allHTTPHeaderFields?.forEach { print("   \($0): \($1)") }
        
        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ApiClientError.networkError(NSError(domain: "", code: -1))
            }
            
            print("📥 Response status code: \(httpResponse.statusCode)")
            print("📥 Response headers:")
            httpResponse.allHeaderFields.forEach { print("   \($0): \($1)") }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Response body: \(responseString)")
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    print("✅ Successfully decoded response")
                    return decoded
                } catch {
                    print("❌ Decoding error: \(error)")
                    throw ApiClientError.decodingError
                }
            case 401:
                await AuthService.shared.logout()
                throw ApiClientError.unauthorized
            case 503:
                throw ApiClientError.serverUnavailable
            default:
                throw ApiClientError.serverError(httpResponse.statusCode)
            }
        } catch let clientError as ApiClientError {
            throw clientError
        } catch {
            throw ApiClientError.networkError(error)
        }
    }
}
