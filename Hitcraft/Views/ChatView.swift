import SwiftUI

struct ChatView: View {
    @Binding var selectedArtist: ArtistProfile
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    @State private var isTyping = false
    @State private var error: Error?
    @State private var showError = false
    @State private var isLoadingHistory = true
    
    private let chatService = ChatService.shared
    
    private var truncatedName: String {
        if selectedArtist.name.count > 12 {
            return String(selectedArtist.name.prefix(12)) + "..."
        }
        return selectedArtist.name
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Artist Header
            MusicianHeader(
                artist: selectedArtist,
                showSwitchOption: true,
                title: "CHAT",
                showTalentGPT: false,
                selectedArtist: $selectedArtist
            )
            
            // Chat Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        if isLoadingHistory {
                            ProgressView()
                                .padding()
                        } else {
                            ForEach(messages) { message in
                                MessageBubble(isFromUser: message.isFromUser, text: message.text)
                                    .id(message.id)
                            }
                        }
                        
                        if isTyping {
                            HStack {
                                Text("Typing")
                                    .font(HitCraftFonts.poppins(12, weight: .light))
                                    .foregroundColor(.gray)
                                TypingIndicator()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 24)
                        }
                    }
                    .padding(.vertical, 16)
                }
                .onChange(of: messages) { _ in
                    if let lastMessage = messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            .background(HitCraftColors.background)
            
            // Message Input
            ChatInput(
                text: $messageText,
                placeholder: "Message \(truncatedName)...",
                isTyping: isTyping,
                onSend: sendMessage
            )
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(error?.localizedDescription ?? "An error occurred")
        }
        .task {
            await loadChatHistory()
        }
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        let userText = messageText
        messageText = ""
        
        // Create and append user message immediately
        let userMessage = ChatMessage(
            content: userText,
            sender: "user"
        )
        messages.append(userMessage)
        
        // Show typing indicator
        isTyping = true
        
        // Send message to API
        Task {
            do {
                let responseMessage = try await chatService.sendMessage(
                    text: userText,
                    artistId: selectedArtist.id
                )
                
                isTyping = false
                messages.append(responseMessage)
            } catch {
                isTyping = false
                self.error = error
                showError = true
            }
        }
    }
    
    private func loadChatHistory() async {
        isLoadingHistory = true
        defer { isLoadingHistory = false }
        
        do {
            messages = try await chatService.getChatHistory(artistId: selectedArtist.id)
        } catch {
            self.error = error
            showError = true
        }
    }
}

#Preview {
    ChatView(selectedArtist: .constant(ArtistProfile.sample))
}
