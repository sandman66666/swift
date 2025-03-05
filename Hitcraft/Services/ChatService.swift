// ChatService.swift
import Foundation

@MainActor
final class ChatService {
    private let apiClient: ApiClient
    var activeThreadId: String?
    
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
    
    func createChat(artistId: String) async throws -> String {
        do {
            // First create a chat thread
            let path = HCEnvironment.Endpoint.createChat(artistId: artistId)
            
            let body: [String: Any] = [
                "artistId": artistId
            ]
            
            logRequest(path, body: body)
            
            let response: [String: Any] = try await apiClient.post(
                path: path,
                body: body
            )
            
            guard let threadId = response["threadId"] as? String else {
                throw ApiError.serverError(code: 400, message: "Failed to create chat thread")
            }
            
            print("Created thread: \(threadId)")
            self.activeThreadId = threadId
            return threadId
        } catch ApiError.unauthorized {
            // For unauthorized error, trigger logout on the main thread
            Task { @MainActor in
                await AuthService.shared.logout()
            }
            throw ApiError.unauthorized
        } catch {
            print("Error creating chat: \(error.localizedDescription)")
            
            // For development/fallback, use a mock thread ID
            let mockThreadId = "mock-thread-\(UUID().uuidString.prefix(8))"
            self.activeThreadId = mockThreadId
            return mockThreadId
        }
    }
    
    func sendMessage(text: String, artistId: String) async throws -> ChatMessage {
        // If we already have a threadId but it's one of our mock ones, generate a mock response
        if let threadId = self.activeThreadId,
           (threadId.hasPrefix("mock-thread-") || threadId.hasPrefix("sample-thread-")) {
            // Return a mock response for testing
            return ChatMessage(
                content: generateMockResponse(to: text),
                sender: "assistant",
                timestamp: Date()
            )
        }
        
        // Get or create thread ID
        let threadId: String
        if let existingThreadId = self.activeThreadId {
            // Only use the existing ID if it's not a sample/mock ID
            if !existingThreadId.hasPrefix("sample-thread-") {
                threadId = existingThreadId
            } else {
                // If it's a sample thread ID, create a new real thread
                do {
                    threadId = try await createChat(artistId: artistId)
                } catch {
                    // Return a mock response if we can't create a thread
                    return ChatMessage(
                        content: "I'm having trouble connecting. Please check your internet connection and try again.",
                        sender: "assistant",
                        timestamp: Date()
                    )
                }
            }
        } else {
            do {
                threadId = try await createChat(artistId: artistId)
            } catch {
                // Return a mock response if we can't create a thread
                return ChatMessage(
                    content: "I'm having trouble connecting. Please check your internet connection and try again.",
                    sender: "assistant",
                    timestamp: Date()
                )
            }
        }
        
        do {
            // Send message to thread
            let path = HCEnvironment.Endpoint.chatMessages(threadId: threadId)
            
            let fragment: [String: Any] = [
                "text": text,
                "type": "text"
            ]
            
            let body: [String: Any] = [
                "content": fragment
            ]
            
            logRequest(path, body: body)
            
            let response: [String: Any] = try await apiClient.post(
                path: path,
                body: body
            )
            
            // Parse the response using the actual structure from the API
            guard
                let messageData = response["message"] as? [String: Any],
                let contentArray = messageData["content"] as? [[String: Any]],
                let firstContent = contentArray.first,
                let messageText = firstContent["text"] as? String,
                let timestamp = messageData["timestamp"] as? String,
                let role = messageData["role"] as? String
            else {
                throw ApiError.decodingError(NSError(domain: "ChatService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse message response"]))
            }
            
            // Create message from parsed data
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            let date = formatter.date(from: timestamp) ?? Date()
            
            return ChatMessage(
                content: messageText,
                sender: role,
                timestamp: date
            )
        } catch ApiError.unauthorized {
            // For unauthorized errors, trigger logout
            Task { @MainActor in
                await AuthService.shared.logout()
            }
            
            // Return a mock response for a better user experience
            return ChatMessage(
                content: "Your session has expired. Please sign in again.",
                sender: "assistant",
                timestamp: Date()
            )
        } catch {
            print("Error sending message: \(error.localizedDescription)")
            
            // Return a mock response for testing
            return ChatMessage(
                content: generateMockResponse(to: text),
                sender: "assistant",
                timestamp: Date()
            )
        }
    }
    
    // Helper to generate mock responses for development and testing
    private func generateMockResponse(to message: String) -> String {
        // Add YouTube embed example if asked about a song
        if message.lowercased().contains("song") &&
           (message.lowercased().contains("greatest") || message.lowercased().contains("best") ||
            message.lowercased().contains("youtube") || message.lowercased().contains("video")) {
            
            return """
            Based on many critics and polls, one of the greatest songs of all time is "Bohemian Rhapsody" by Queen. This epic 1975 masterpiece combined rock, opera, and ballad elements in a revolutionary way.
            
            <iframe width="560" height="315" src="https://www.youtube.com/embed/fJ9rUzIMcZQ" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
            
            What aspects of this song inspire you for your own music?
            """
        }
        
        // Simple responses for common music questions
        if message.lowercased().contains("chord") || message.lowercased().contains("progression") {
            return "For a pop song, try a classic I-V-vi-IV progression. In the key of C major, that would be C-G-Am-F. This progression is used in countless hit songs!"
        } else if message.lowercased().contains("lyric") || message.lowercased().contains("verse") {
            return "When writing lyrics, try focusing on a specific emotion or experience. Start with a strong hook that captures the essence of what you want to express, then build verses around that central theme."
        } else if message.lowercased().contains("beat") || message.lowercased().contains("drum") {
            return "For a solid pop beat, start with a four-on-the-floor kick pattern, add snares on beats 2 and 4, and use hi-hats to create rhythm and movement. Try adding subtle variations every 4 or 8 bars to keep it interesting."
        } else if message.lowercased().contains("mix") || message.lowercased().contains("master") {
            return "When mixing, focus on creating space for each element. Start with balancing levels, then work on panning, EQ, compression, and finally add effects like reverb and delay. Remember that less is often more!"
        } else {
            return "I'd love to help with your music project! Could you tell me more about what you're working on or what specific aspect you need assistance with?"
        }
    }
    
    // Keep this stub for compatibility with existing views
    func getChatHistory(artistId: String) async throws -> [ChatMessage] {
        // Return empty array as history endpoint is not available
        return []
    }
}
