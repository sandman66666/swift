// Components.swift - Shared UI components
import SwiftUI

// DetailRow component for displaying label-value pairs
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

// Common UI components
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
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(HitCraftColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(HitCraftColors.border, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Standard section header
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(HitCraftFonts.subheader())
            .foregroundColor(HitCraftColors.text)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 12)
    }
}

// Standard screen header
struct ScreenHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Spacer()
            Text(title)
                .font(HitCraftFonts.header())
                .foregroundColor(HitCraftColors.text)
            Spacer()
        }
        .frame(height: 44)
        .padding(.horizontal, 20)
        .background(HitCraftColors.headerFooterBackground)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}
