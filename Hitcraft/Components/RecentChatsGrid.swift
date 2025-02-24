// RecentChatsGrid.swift
import SwiftUI

struct RecentChatsGrid: View {
    var body: some View {
        VStack(spacing: 12) {
            RecentChatCard(title: "Need help with my 2nd verse...", time: "1 day ago")
            RecentChatCard(title: "Catchy drop ideas", time: "3 days ago")
            RecentChatCard(title: "Pop ballad production", time: "4 days ago")
        }
    }
}

struct RecentChatCard: View {
    let title: String
    let time: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(HitCraftFonts.poppins(14, weight: .light))
            HStack {
                Image(systemName: "clock")
                Text(time)
            }
            .font(HitCraftFonts.poppins(12, weight: .light))
            .foregroundColor(.gray)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(HitCraftColors.border, lineWidth: 1)
        )
    }
}

#Preview {
    RecentChatsGrid()
        .padding()
}
