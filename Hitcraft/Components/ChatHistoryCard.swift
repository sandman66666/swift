import SwiftUI

// First, add the DetailRow component directly in this file
struct DetailRow: View {
    let title: String
    let value: String
    var isLink: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(HitCraftFonts.caption())
                .foregroundColor(HitCraftColors.secondaryText)
            Text(value)
                .font(HitCraftFonts.body())
                .foregroundColor(isLink ? HitCraftColors.accent : HitCraftColors.text)
        }
    }
}

// ChatHistoryCard component for both HistoryView and ChatSummaryView
struct ChatHistoryCardView: View {
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
                        .font(HitCraftFonts.body())
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
                        .font(HitCraftFonts.caption())
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
        .clipShape(RoundedRectangle(cornerRadius: HitCraftLayout.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: HitCraftLayout.cardCornerRadius)
                .stroke(HitCraftColors.border, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
