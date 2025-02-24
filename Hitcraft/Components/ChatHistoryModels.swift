import SwiftUI

// Models needed for HistoryView and ChatSummaryView
struct ChatItem: Identifiable {
    let id = UUID()
    let title: String
    var details: ChatDetails?
    var threadId: String?
    
    init(title: String, details: ChatDetails? = nil, threadId: String? = nil) {
        self.title = title
        self.details = details
        self.threadId = threadId
    }
}

struct ChatDetails {
    let pluginName: String
    let year: String
    let presetLink: String
    
    init(pluginName: String, year: String, presetLink: String) {
        self.pluginName = pluginName
        self.year = year
        self.presetLink = presetLink
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
