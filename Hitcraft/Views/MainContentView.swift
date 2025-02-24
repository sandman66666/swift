import SwiftUI

struct MainContentView: View {
    @Binding var selectedArtist: ArtistProfile
    @State private var navigationPath = NavigationPath()
    @State private var showingChat = false
    @State private var showingSidebar = false
    @State private var initialMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                HitCraftColors.background
                    .ignoresSafeArea()
                
                // Main Content
                HomeView(selectedArtist: $selectedArtist)
                
                // Custom sidebar transition from left
                if showingSidebar {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 0.3)) {
                                showingSidebar = false
                            }
                        }
                    
                    HStack(spacing: 0) {
                        SidebarView(
                            isOpen: $showingSidebar,
                            selectedArtist: $selectedArtist
                        )
                        .frame(width: UIScreen.main.bounds.width * 0.85)
                        .background(Color.white)
                        .transition(.move(edge: .leading))
                        
                        Spacer()
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    MainContentView(selectedArtist: .constant(ArtistProfile.sample))
}
