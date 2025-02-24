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

// Models
struct ChatItem: Identifiable {
    let id = UUID()
    let title: String
    var details: ChatDetails?
}

struct ChatDetails {
    let pluginName: String
    let year: String
    let presetLink: String
}

// Components
struct ChatHistoryCard: View {
    let item: ChatItem
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title row with chat bubble
            Button(action: onTap) {
                HStack(alignment: .top, spacing: 12) {
                    Image("chatbubble")
                        .resizable()
                        .frame(width: 20, height: 20)
                    
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
                    
                    Button(action: {}) {
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
            }
        }
        .padding(.vertical, 19)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HitCraftColors.background)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(HitCraftColors.border, lineWidth: 1)
        )
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    var isLink: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(HitCraftFonts.poppins(12, weight: .light))
                .foregroundColor(.gray)
            Text(value)
                .font(HitCraftFonts.poppins(14, weight: .light))
                .foregroundColor(isLink ? .blue : .black)
        }
    }
}

#Preview {
    ChatSummaryView(
        isOpen: .constant(true),
        selectedArtist: .constant(ArtistProfile.sample)
    )
}
