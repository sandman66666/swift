import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var authService: AuthService
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Spacer()
                Text("SETTINGS")
                    .font(HitCraftFonts.poppins(18, weight: .light))
                    .foregroundColor(.black)
                Spacer()
            }
            .frame(height: 44)
            .padding(.horizontal, 20)
            .background(Color.white)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Profile")
                            .font(HitCraftFonts.poppins(18, weight: .medium))
                            .padding(.horizontal, 20)
                        
                        SettingsCard {
                            HStack {
                                Circle()
                                    .fill(HitCraftColors.accent.opacity(0.1))
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .foregroundColor(HitCraftColors.accent)
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Your Account")
                                        .font(HitCraftFonts.poppins(16, weight: .medium))
                                    Text("Profile details and preferences")
                                        .font(HitCraftFonts.poppins(14, weight: .light))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.top, 20)
                    
                    // App Settings
                    VStack(alignment: .leading, spacing: 16) {
                        Text("App Settings")
                            .font(HitCraftFonts.poppins(18, weight: .medium))
                            .padding(.horizontal, 20)
                        
                        // Notifications
                        SettingsCard {
                            SettingsRow(icon: "bell.fill", title: "Notifications", subtitle: "Configure app notifications")
                        }
                        
                        // Appearance
                        SettingsCard {
                            SettingsRow(icon: "paintbrush.fill", title: "Appearance", subtitle: "Dark mode, theme")
                        }
                        
                        // Storage & Data
                        SettingsCard {
                            SettingsRow(icon: "externaldrive.fill", title: "Storage & Data", subtitle: "Manage app storage and data usage")
                        }
                    }
                    
                    // Help and Support
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Help & Support")
                            .font(HitCraftFonts.poppins(18, weight: .medium))
                            .padding(.horizontal, 20)
                        
                        // Contact Support
                        SettingsCard {
                            SettingsRow(icon: "questionmark.circle.fill", title: "Contact Support", subtitle: "Get help with issues")
                        }
                        
                        // About
                        SettingsCard {
                            SettingsRow(icon: "info.circle.fill", title: "About Hitcraft", subtitle: "Version, legal info and credits")
                        }
                    }
                    
                    // Logout Button
                    Button(action: {
                        Task {
                            await authService.logout()
                        }
                    }) {
                        Text("Log Out")
                            .font(HitCraftFonts.poppins(16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(HitCraftColors.primaryGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 30)
                    .padding(.bottom, 20)
                }
            }
        }
        .background(HitCraftColors.background)
    }
}

struct SettingsCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 20)
    }
}

struct SettingsRow: View {
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
                    .font(HitCraftFonts.poppins(16, weight: .medium))
                Text(subtitle)
                    .font(HitCraftFonts.poppins(14, weight: .light))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(Services.shared.auth)
}
