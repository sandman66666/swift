// File: Hitcraft/Views/ChatHistoryView.swift

import SwiftUI

struct ChatHistoryView: View {
    @State private var chatHistory: [ChatMessage] = []
    @State private var errorMessage: String?
    
    var artistId: String
    
    private let chatService = ChatService.shared
    
    var body: some View {
        VStack {
            // Display the error message or chat history
            if let errorMessage = errorMessage {
                // If there's an error (e.g., no chat history), show an error message
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else {
                // List of chat messages
                List(chatHistory) { message in
                    Text(message.content)
                        .padding()
                        .background(message.isFromUser ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
        .onAppear {
            loadChatHistory()
        }
    }
    
    // Load chat history when the view appears
    private func loadChatHistory() {
        Task {
            do {
                // Try to fetch the chat history from the server
                chatHistory = try await chatService.getChatHistory(artistId: artistId)
            } catch {
                // Handle errors like "No chat history available"
                if let apiError = error as? ApiError, case .serverError(_, let message) = apiError {
                    errorMessage = message ?? "An unknown error occurred"
                } else {
                    errorMessage = "An unknown error occurred"
                }
            }
        }
    }
}

struct ChatHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        ChatHistoryView(artistId: "67618ad67dc13643acff6a25")
    }
}
