import SwiftUI

struct MessageBubble: View {
    let isFromUser: Bool
    let text: String
    @ObservedObject private var themeManager = ThemeManager.shared
    
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
                    .font(HitCraftFonts.body())
                    .foregroundColor(HitCraftColors.text)
                    .lineSpacing(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if !isFromUser {
                    Spacer(minLength: 32)
                }
            }
            .padding(HitCraftLayout.messagePadding)
            .frame(maxWidth: .infinity)
            .background(isFromUser ? HitCraftColors.userMessageBackground : HitCraftColors.systemMessageBackground)
            .clipShape(RoundedRectangle(cornerRadius: HitCraftLayout.messageBubbleRadius))
            .shadow(color: Color.black.opacity(themeManager.currentTheme == .dark ? 0.3 : 0.05), radius: 2, x: 0, y: 1)
        }
        .padding(.horizontal, 8)
        // Add animation for new messages
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
}

struct TypingIndicator: View {
    @State private var dotOffset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(HitCraftColors.secondaryText)
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
    
    // Send button color based on theme and state
    private var sendButtonColor: Color {
        if text.isEmpty || isTyping {
            return ThemeManager.shared.currentTheme == .dark ?
                Color.gray.opacity(0.6) : Color.gray.opacity(0.4)
        } else {
            return ThemeManager.shared.currentTheme == .dark ?
                Color.white : Color.black
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(HitCraftColors.border)
            
            VStack(spacing: 12) {
                // Input field with embedded send button
                HStack(spacing: 0) {
                    TextField(placeholder, text: $text)
                        .font(HitCraftFonts.body())
                        .padding(.leading, 16)
                        .padding(.trailing, 8)
                        .padding(.vertical, 12)
                        .foregroundColor(HitCraftColors.text)
                    
                    // Send button inside the input area
                    Button(action: onSend) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(sendButtonColor)
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(ThemeManager.shared.currentTheme == .dark ?
                                          Color.gray.opacity(0.3) : Color.gray.opacity(0.1))
                            )
                            .padding(.trailing, 12)
                    }
                    .disabled(text.isEmpty || isTyping)
                    .hitCraftStyle()
                    .scaleEffect(isTyping ? 0.95 : 1.0)
                }
                .background(HitCraftColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: HitCraftLayout.cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: HitCraftLayout.cornerRadius)
                        .stroke(HitCraftColors.border, lineWidth: 1)
                )
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 12)
            .background(HitCraftColors.headerFooterBackground)
        }
    }
}
