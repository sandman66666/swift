import SwiftUI

struct HistoryView: View {
    @State private var searchText = ""
    @State private var expandedCardId: UUID? = nil
    @ObservedObject private var themeManager = ThemeManager.shared
    
    // Sample chat items - these would come from your API in a real app
    private let chatItems = [
        ChatItem(
            title: "Need help with my 2nd verse lyrics",
            threadId: "sample-thread-1"
        ),
        ChatItem(
            title: "I need some help with good presets for kick drum sound",
            details: ChatDetails(
                pluginName: "12/07/92",
                year: "2003",
                presetLink: "https://knightsoftheedit..."
            ),
            threadId: "sample-thread-2"
        ),
        ChatItem(title: "Catchy drop ideas", threadId: "sample-thread-3"),
        ChatItem(title: "Pop ballad production", threadId: "sample-thread-4"),
        ChatItem(title: "Recommend the right tempo for my song", threadId: "sample-thread-5")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Header
            HStack {
                Spacer()
                Text("HISTORY")
                    .font(HitCraftFonts.header())
                    .foregroundColor(HitCraftColors.text)
                Spacer()
            }
            .frame(height: 44)
            .padding(.horizontal, 20)
            .background(HitCraftColors.headerFooterBackground)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(HitCraftColors.secondaryText)
                TextField("Search chats...", text: $searchText)
                    .font(HitCraftFonts.body())
                    .foregroundColor(HitCraftColors.text)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(HitCraftColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(HitCraftColors.border, lineWidth: 1)
            )
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 10)
            
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(chatItems) { item in
                        ChatHistoryCardView(
                            item: item,
                            isExpanded: expandedCardId == item.id,
                            onTap: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    if expandedCardId == item.id {
                                        expandedCardId = nil
                                    } else {
                                        expandedCardId = item.id
                                    }
                                }
                            },
                            onLoadChat: {
                                loadChat(item: item)
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
            }
            .background(HitCraftColors.background)
        }
        .background(HitCraftColors.background)
        .animation(.easeInOut(duration: 0.3), value: themeManager.currentTheme)
    }
    
    private func loadChat(item: ChatItem) {
        // Here you would load the chat thread by ID
        // And then navigate to the chat view
        if let threadId = item.threadId {
            // Set the thread ID in ChatService
            ChatService.shared.activeThreadId = threadId
            
            // Save current time for the chat freshness check
            UserDefaults.standard.set(Date(), forKey: "lastChatTime")
            
            // Save in UserDefaults that we're loading from history
            // This helps the ChatContentView know it needs to load history
            UserDefaults.standard.set(true, forKey: "loadingFromHistory")
            
            // Navigate to the chat tab
            NotificationCenter.default.post(
                name: NSNotification.Name("SwitchToTab"),
                object: nil,
                userInfo: ["tab": MenuTab.chat]
            )
        }
    }
}

#Preview {
    HistoryView()
}
