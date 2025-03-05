import SwiftUI

struct ChatContentView: View {
    let defaultArtist: ArtistProfile
    @State private var messages: [ChatMessage] = []
    @State private var messageText = ""
    @State private var isTyping = false
    @State private var error: Error?
    @State private var showError = false
    @State private var isLoadingMessages = true
    @State private var scrollViewProxy: ScrollViewProxy? = nil
    @State private var keyboardHeight: CGFloat = 0
    @State private var bottomPadding: CGFloat = 80 // Increased padding space above the message bar
    
    // Background color for header and bottom areas
    private let headerFooterColor = HitCraftColors.headerFooterBackground
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Header with new chat button
            HStack {
                Spacer()
                Text("CHAT")
                    .font(HitCraftFonts.header())
                    .foregroundColor(HitCraftColors.text)
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
                .hitCraftStyle()
            }
            .frame(height: 44)
            .padding(.leading, 20)
            .background(headerFooterColor)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            
            // Chat Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: HitCraftLayout.messageBubbleSpacing) {
                        if isLoadingMessages {
                            ProgressView()
                                .padding()
                        } else if messages.isEmpty {
                            VStack(spacing: 16) {
                                Text("Start a new conversation")
                                    .font(HitCraftFonts.subheader())
                                    .foregroundColor(HitCraftColors.text)
                                Text("Ask for help with your music production, lyrics, or any other musical needs.")
                                    .font(HitCraftFonts.body())
                                    .foregroundColor(HitCraftColors.secondaryText)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .padding(.top, 100)
                        } else {
                            ForEach(messages) { message in
                                MessageBubble(isFromUser: message.isFromUser, text: message.text)
                                    .id(message.id)
                                    .transition(.asymmetric(
                                        insertion: .scale(scale: 0.98).combined(with: .opacity),
                                        removal: .opacity
                                    ))
                            }
                        }
                        
                        if isTyping {
                            HStack {
                                Text("Typing")
                                    .font(HitCraftFonts.caption())
                                    .foregroundColor(HitCraftColors.secondaryText)
                                TypingIndicator()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 24)
                            .id("typingIndicator")
                            .transition(.opacity)
                        }
                        
                        // Invisible spacer at the bottom with increased height
                        Color.clear
                            .frame(height: bottomPadding)
                            .id("bottomSpacer")
                    }
                    .padding(.vertical, 16)
                }
                .onChange(of: messages) { _ in
                    scrollToBottom(proxy: proxy, animated: true)
                }
                .onChange(of: isTyping) { newValue in
                    if newValue {
                        // If typing indicator appears, scroll to it
                        scrollToTypingIndicator(proxy: proxy)
                    }
                }
                .onAppear {
                    self.scrollViewProxy = proxy
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                    if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                        self.keyboardHeight = keyboardFrame.height
                        // When keyboard appears, ensure we scroll to the bottom
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            scrollToBottom(proxy: proxy, animated: true)
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                    self.keyboardHeight = 0
                }
            }
            .background(HitCraftColors.background)
            
            // Custom Input Bar with embedded send button
            ChatInput(
                text: $messageText,
                placeholder: "Type your message...",
                isTyping: isTyping,
                onSend: sendMessage
            )
        }
        .task {
            await loadChat()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(error?.localizedDescription ?? "An error occurred")
                .font(HitCraftFonts.body())
                .foregroundColor(HitCraftColors.text)
        }
    }
    
    // Function to scroll to bottom of chat with simplified animation to avoid NaN errors
    private func scrollToBottom(proxy: ScrollViewProxy, animated: Bool = true) {
        if animated {
            withAnimation(.easeOut(duration: 0.3)) {
                if let lastMessage = messages.last {
                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                } else if isTyping {
                    proxy.scrollTo("typingIndicator", anchor: .bottom)
                } else {
                    proxy.scrollTo("bottomSpacer", anchor: .bottom)
                }
            }
        } else {
            if let lastMessage = messages.last {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            } else if isTyping {
                proxy.scrollTo("typingIndicator", anchor: .bottom)
            } else {
                proxy.scrollTo("bottomSpacer", anchor: .bottom)
            }
        }
    }
    
    // Function to scroll to typing indicator with simplified animation
    private func scrollToTypingIndicator(proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.3)) {
            proxy.scrollTo("typingIndicator", anchor: .bottom)
        }
    }
    
    func loadChat() async {
        isLoadingMessages = true
        
        // Check if we're loading a specific thread
        if let threadId = ChatService.shared.activeThreadId {
            print("Loading existing thread: \(threadId)")
            
            // Create messages array first, then assign it to messages state variable
            let historyMessages: [ChatMessage] = [
                ChatMessage(
                    content: "Welcome back to our conversation! How can I help you today?",
                    sender: "assistant",
                    timestamp: Date().addingTimeInterval(-3600) // 1 hour ago
                ),
                ChatMessage(
                    content: "I was working on a song earlier",
                    sender: "user",
                    timestamp: Date().addingTimeInterval(-3500) // 58 minutes ago
                ),
                ChatMessage(
                    content: "Great! I remember we were discussing your song. Would you like to continue where we left off?",
                    sender: "assistant",
                    timestamp: Date().addingTimeInterval(-3450) // 57 minutes ago
                )
            ]
            
            isLoadingMessages = false
            
            // Use a simple animation approach to avoid NaN errors
            withAnimation(.easeIn(duration: 0.3)) {
                messages = historyMessages
            }
            
            // Scroll to bottom after loading messages
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.scrollToBottom(proxy: self.scrollViewProxy!, animated: true)
            }
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
            
            isLoadingMessages = false
            
            // Use a simpler animation to avoid NaN errors
            withAnimation(.easeIn(duration: 0.3)) {
                messages = [welcomeMessage, message]
            }
            
            // Scroll to bottom after loading messages
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.scrollToBottom(proxy: self.scrollViewProxy!, animated: true)
            }
        } catch {
            self.error = error
            showError = true
            isLoadingMessages = false
        }
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        let userText = messageText
        messageText = ""
        
        // Create user message
        let userMessage = ChatMessage(
            content: userText,
            sender: "user"
        )
        
        // Add user message with simple animation
        withAnimation(.easeIn(duration: 0.3)) {
            messages.append(userMessage)
        }
        
        // Show typing indicator
        withAnimation(.easeIn(duration: 0.3)) {
            isTyping = true
        }
        
        // Ensure we scroll to the typing indicator
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.scrollViewProxy != nil {
                self.scrollToTypingIndicator(proxy: self.scrollViewProxy!)
            }
        }
        
        // Send message to API
        Task {
            do {
                // Add a small artificial delay to make it feel more natural
                try await Task.sleep(nanoseconds: 600_000_000) // 0.6 seconds
                
                let responseMessage = try await ChatService.shared.sendMessage(
                    text: userText,
                    artistId: defaultArtist.id
                )
                
                // Hide typing indicator with animation
                withAnimation(.easeOut(duration: 0.2)) {
                    isTyping = false
                }
                
                // Short pause before showing the response
                try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
                
                // Add the response message with animation
                withAnimation(.easeIn(duration: 0.3)) {
                    messages.append(responseMessage)
                }
                
                // Scroll to the new message
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if self.scrollViewProxy != nil {
                        self.scrollToBottom(proxy: self.scrollViewProxy!, animated: true)
                    }
                }
            } catch {
                withAnimation {
                    isTyping = false
                }
                self.error = error
                showError = true
            }
        }
    }
}
