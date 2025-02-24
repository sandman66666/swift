// File: Hitcraft/Views/ChatMainView.swift

import SwiftUI

struct ChatMainView: View {
    @State private var artistId: String = "67618ad67dc13643acff6a25" // Example artist ID
    @State private var chatHistory: [ChatMessage] = []
    @State private var errorMessage: String?
    @State private var messageText: String = "" // New state for message text input
    
    // Service to handle fetching chat history
    private let chatService = ChatService.shared
    
    var body: some View {
        VStack {
            // Display chat history or error message
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
            
            // Sending a new message
            HStack {
                TextField("Type your message", text: $messageText)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                
                Button(action: sendMessage) {
                    Text("Send")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(messageText.isEmpty) // Disable send button if message is empty
            }
            .padding()
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
    
    // Send a new message to the chat
    private func sendMessage() {
        Task {
            do {
                // Call the service to send a new message
                _ = try await chatService.sendMessage(text: messageText, artistId: artistId)
                
                // Clear the input field
                messageText = ""
                
                // After sending, reload the chat history to show the new message
                loadChatHistory()
            } catch {
                errorMessage = "Failed to send message"
            }
        }
    }
}

struct ChatMainView_Previews: PreviewProvider {
    static var previews: some View {
        ChatMainView()
    }
}
