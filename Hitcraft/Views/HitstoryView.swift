import SwiftUI

struct HistoryView: View {
    @State private var searchText = ""
    @State private var expandedCardId: UUID? = nil
    
    // Darker background color for header and bottom areas
    private let darkAreaColor = Color(hex: "F0F0F0").opacity(0.9)
    
    // Sample chat items - these would come from your API in a real app
    private let chatItems = [
        ChatItem(
            title: "Need help with my 2nd verse lyrics",
            threadId: "sample-thread-1"
        ),
        ChatItem(
            title: "I need some help with good presets for my kick drum sound",
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
            // Top Header - darker background
            HStack {
                Spacer()
                Text("HISTORY")
                    .font(HitCraftFonts.poppins(18, weight: .light))
                    .foregroundColor(.black)
                Spacer()
            }
            .frame(height: 44)
            .padding(.horizontal, 20)
            .background(darkAreaColor)
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search chats...", text: $searchText)
                    .font(HitCraftFonts.poppins(15, weight: .light))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(HitCraftColors.border, lineWidth: 1)
            )
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(chatItems) { item in
                        ChatHistoryCard(
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
                .padding(.top, 20)
            }
            .background(HitCraftColors.background)
        }
        .background(HitCraftColors.background)
    }
    
    private func loadChat(item: ChatItem) {
        // Here you would load the chat thread by ID
        // And then navigate to the chat view
        if let threadId = item.threadId {
            // Set the thread ID in ChatService
            ChatService.shared.activeThreadId = threadId
            
            // Save current time for the chat freshness check
            UserDefaults.standard.set(Date(), forKey: "lastChatTime")
            
            // Navigate to the chat tab
            NotificationCenter.default.post(
                name: NSNotification.Name("SwitchToTab"),
                object: nil,
                userInfo: ["tab": MenuTab.chat]
            )
        }
    }
}

// Components
struct ChatHistoryCard: View {
    let item: ChatItem
    let isExpanded: Bool
    let onTap: () -> Void
    let onLoadChat: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title row with chat bubble
            Button(action: onTap) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "bubble.left.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(HitCraftColors.accent.opacity(0.6))
                    
                    Text(item.title)
                        .font(HitCraftFonts.poppins(14, weight: .light))
                        .foregroundColor(HitCraftColors.text)
                        .lineSpacing(6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Expanded details
            if isExpanded, let details = item.details {
                VStack(alignment: .leading, spacing: 8) {
                    DetailRow(title: "Plugin name", value: details.pluginName)
                    DetailRow(title: "Year", value: details.year)
                    DetailRow(title: "link to preset", value: details.presetLink, isLink: true)
                    
                    Button(action: onLoadChat) {
                        HStack {
                            Text("Take me to this Chat")
                                .font(HitCraftFonts.poppins(14, weight: .medium))
                                .foregroundColor(HitCraftColors.accent)
                            Image(systemName: "arrow.right")
                                .foregroundColor(HitCraftColors.accent)
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(.leading, 32)
            } else if !isExpanded {
                // Always show a "Go to Chat" button even when not expanded
                Button(action: onLoadChat) {
                    Text("Open chat")
                        .font(HitCraftFonts.poppins(12, weight: .medium))
                        .foregroundColor(HitCraftColors.accent)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(HitCraftColors.accent.opacity(0.1))
                        .clipShape(Capsule())
                }
                .padding(.leading, 32)
            }
        }
        .padding(.vertical, 19)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(HitCraftColors.border, lineWidth: 1)
        )
    }
}
