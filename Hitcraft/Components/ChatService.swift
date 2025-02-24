// ChatService.swift
import Foundation

@MainActor
final class ChatService {
    private let apiClient: ApiClient
    
    static let shared = ChatService(apiClient: .shared)
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    private func logRequest(_ path: String, body: [String: Any]? = nil) {
        print("📍 API Path: \(path)")
        if let body = body {
            print("📦 Request Body: \(body)")
        }
    }
    
    func sendMessage(text: String, artistId: String) async throws -> ChatMessage {
        // Use the send endpoint
        let path = HCEnvironment.Endpoint.chatSend(artistId)
        let timestamp = ISO8601DateFormatter().string(from: Date())
        
        // Full request payload
        let body: [String: Any] = [
            "artistId": artistId,
            "message": [
                "content": text,
                "type": "text",
                "sender": "user",
                "timestamp": timestamp
            ]
        ]
        
        logRequest(path, body: body)
        
        let response: ChatResponse = try await apiClient.post(
            path: path,
            body: body
        )
        
        guard let data = response.data else {
            throw ApiError.serverError(code: 400, message: response.error ?? "Unknown error")
        }
        
        return data.message
    }
    
    func getChatHistory(artistId: String) async throws -> [ChatMessage] {
        // Use a separate endpoint for history
        let path = HCEnvironment.Endpoint.chatHistory(artistId)
        logRequest(path)
        
        let response: ChatHistoryResponse = try await apiClient.get(path: path)
        
        guard let data = response.data else {
            throw ApiError.serverError(code: 400, message: response.error ?? "Unknown error")
        }
        
        return data.messages.sorted { $0.timestamp < $1.timestamp }
    }
}
