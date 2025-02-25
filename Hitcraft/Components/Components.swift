import SwiftUI

// Common UI components
struct ComponentDetailRow: View {  // Renamed to avoid conflict
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
