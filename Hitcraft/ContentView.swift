import SwiftUI

struct ChatContentView: View {
    let defaultArtist: ArtistProfile
    @State private var messages: [ChatMessage] = []
    @State private var messageText = ""
    @State private var isTyping = false
    @State private var error: Error?
    @State private var showError = false
    @State private var isLoadingMessages = true
    
    // Darker background color for header and bottom areas
    private let darkAreaColor = Color(hex: "E0E0E0")
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Header with new chat button - darker background
            HStack {
                Spacer()
                Text("CHAT")
                    .font(HitCraftFonts.poppins(18, weight: .light))
                    .foregroundColor(.black)
                Spacer()
                
                // New Chat Button
                Button(action: {
                    // Start new chat
                    Task {
                        ChatService.shared.activeThreadId = nil
                        await loadInitialChat()
                    }
                }) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 20))
                        .foregroundColor(HitCraftColors.accent)
                }
                .padding(.trailing, 20)
            }
            .frame(height: 44)
            .padding(.leading, 20)
            .background(darkAreaColor)
            
            // Chat Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        if isLoadingMessages {
                            ProgressView()
                                .padding()
                        } else if messages.isEmpty {
                            VStack(spacing: 16) {
                                Text("Start a new conversation")
                                    .font(HitCraftFonts.poppins(18, weight: .medium))
                                Text("Ask for help with your music production, lyrics, or any other musical needs.")
                                    .font(HitCraftFonts.poppins(14, weight: .light))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .padding(.top, 100)
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
            
            // Custom Input Bar - no border, darker background
            HStack {
                TextField("Message HitCraft...", text: $messageText)
                    .font(HitCraftFonts.poppins(15, weight: .light))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(darkAreaColor)
                    .foregroundColor(.primary)
                
                Button(action: sendMessage) {
                    Circle()
                        .fill(HitCraftColors.primaryGradient)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "arrow.up")
                                .foregroundColor(.white)
                        )
                }
                .disabled(messageText.isEmpty || isTyping)
                .padding(.trailing, 16)
            }
            .padding(.vertical, 10)
            .background(darkAreaColor)
        }
        .task {
            await loadChat()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(error?.localizedDescription ?? "An error occurred")
        }
    }
    
    func loadChat() async {
        isLoadingMessages = true
        
        // Check if we're loading a specific thread
        if let threadId = ChatService.shared.activeThreadId {
            print("Loading existing thread: \(threadId)")
            
            // For a real app, you'd load messages from this thread
            // Since we don't have a get thread messages endpoint, we'll generate mock messages
            
            // Add a welcome message and a fake previous message exchange
            let welcomeMessage = ChatMessage(
                content: "Welcome back to our conversation! How can I help you today?",
                sender: "assistant",
                timestamp: Date().addingTimeInterval(-3600) // 1 hour ago
            )
            
            let userMessage = ChatMessage(
                content: "I was working on a song earlier",
                sender: "user",
                timestamp: Date().addingTimeInterval(-3500) // 58 minutes ago
            )
            
            let assistantResponse = ChatMessage(
                content: "Great! I remember we were discussing your song. Would you like to continue where we left off?",
                sender: "assistant",
                timestamp: Date().addingTimeInterval(-3450) // 57 minutes ago
            )
            
            messages = [welcomeMessage, userMessage, assistantResponse]
            isLoadingMessages = false
        } else {
            // Start a new chat
            await loadInitialChat()
        }
    }
    
    func loadInitialChat() async {
        isLoadingMessages = true
        do {
            // Create a new chat with welcome message
            let message = try await ChatService.shared.sendMessage(
                text: "Hello, I'd like to create music",
                artistId: defaultArtist.id
            )
            
            // Add an initial welcome message
            let welcomeMessage = ChatMessage(
                content: "Welcome! I'm HitCraft, your AI music assistant. How can I help with your music today?",
                sender: "assistant"
            )
            
            messages = [welcomeMessage, message]
        } catch {
            self.error = error
            showError = true
        }
        isLoadingMessages = false
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
                let responseMessage = try await ChatService.shared.sendMessage(
                    text: userText,
                    artistId: defaultArtist.id
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
}
