import SwiftUI

struct ChatSummaryView: View {
    @Binding var isOpen: Bool
    @Binding var selectedArtist: ArtistProfile
    @State private var searchText = ""
    @State private var expandedCardId: UUID? = nil
    
    // Sample chat items
    private let chatItems = [
        ChatItem(title: "Need help with my 2nd verse lyrics"),
        ChatItem(
            title: "I need some help with good presets for my kick drum sound",
            details: ChatDetails(
                pluginName: "12/07/92",
                year: "2003",
                presetLink: "https://knightsoftheedit..."
            )
        ),
        ChatItem(title: "Catchy drop ideas"),
        ChatItem(title: "Pop ballad production"),
        ChatItem(title: "Recommend the right tempo for my song")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Header
            MusicianHeader(
                artist: selectedArtist,
                showSwitchOption: true,
                title: "HISTORY",
                showTalentGPT: false,
                selectedArtist: $selectedArtist
            )
            
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
                                // Handle loading chat from history
                                if let threadId = item.threadId {
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
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .background(Color.white)
    }
}

#Preview {
    ChatSummaryView(
        isOpen: .constant(true),
        selectedArtist: .constant(ArtistProfile.sample)
    )
}
