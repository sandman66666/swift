// UIComponents.swift
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

// Settings card component
struct HitCraftSettingsCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(HitCraftColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 20)
    }
}

// Settings row component
struct HitCraftSettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack {
            Circle()
                .fill(HitCraftColors.accent.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: icon)
                        .foregroundColor(HitCraftColors.accent)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(HitCraftFonts.subheader())
                    .foregroundColor(HitCraftColors.text)
                Text(subtitle)
                    .font(HitCraftFonts.body())
                    .foregroundColor(HitCraftColors.secondaryText)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(HitCraftColors.secondaryText)
        }
    }
}
