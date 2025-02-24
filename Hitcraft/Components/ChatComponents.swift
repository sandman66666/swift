// ChatComponents.swift
import SwiftUI

struct MessageBubble: View {
    let isFromUser: Bool
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                if isFromUser {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.gray)
                }
                
                Text(text)
                    .font(HitCraftFonts.poppins(15, weight: .light))
                    .foregroundColor(Color(hex: "424246"))
                    .lineSpacing(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if !isFromUser {
                    Spacer(minLength: 32)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(isFromUser ? Color(hex: "F1E4E9") : Color(hex: "EFE9F4"))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 8)
    }
}

struct TypingIndicator: View {
    @State private var dotOffset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.gray)
                    .frame(width: 6, height: 6)
                    .offset(y: dotOffset)
                    .animation(
                        Animation.easeInOut(duration: 0.5)
                            .repeatForever()
                            .delay(0.2 * Double(index)),
                        value: dotOffset
                    )
            }
        }
        .onAppear {
            dotOffset = -5
        }
    }
}

struct ChatInput: View {
    @Binding var text: String
    let placeholder: String
    let isTyping: Bool
    let onSend: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(HitCraftColors.border)
            
            VStack(spacing: 12) {
                HStack {
                    TextField(placeholder, text: $text)
                        .font(HitCraftFonts.poppins(15, weight: .light))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(HitCraftColors.border, lineWidth: 1)
                        )
                        .onSubmit(onSend)
                    
                    Button(action: onSend) {
                        Circle()
                            .fill(HitCraftColors.primaryGradient)
                            .frame(width: 44, height: 44)
                            .overlay(
                                Image(systemName: "arrow.up")
                                    .foregroundColor(.white)
                            )
                    }
                    .disabled(text.isEmpty || isTyping)
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 12)
            .background(Color.white)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        MessageBubble(isFromUser: true, text: "Hello, I need help with my lyrics")
        MessageBubble(isFromUser: false, text: "I'll be happy to help you with your lyrics! What kind of song are you working on?")
        HStack {
            Text("Typing")
            TypingIndicator()
        }
        ChatInput(
            text: .constant(""),
            placeholder: "Type a message...",
            isTyping: false,
            onSend: {}
        )
    }
    .padding()
}
