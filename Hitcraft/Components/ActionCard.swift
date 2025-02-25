// ActionCard.swift
import SwiftUI

struct ActionCard: View {
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .center, spacing: 4) {
                Text(title)
                    .font(HitCraftFonts.subheader())
                    .foregroundColor(HitCraftColors.text)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(HitCraftFonts.caption())
                    .foregroundColor(HitCraftColors.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
    }
}
