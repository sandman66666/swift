import SwiftUI
import WebKit

struct MessageBubble: View {
    let isFromUser: Bool
    let text: String
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var youtubeEmbedData: YouTubeEmbedData? = nil
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                if isFromUser {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.gray)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    if let embedData = youtubeEmbedData {
                        // If there's text before the YouTube embed
                        if !embedData.textBefore.isEmpty {
                            FormattedText(text: embedData.textBefore)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 8)
                        }
                        
                        // YouTube Embed View
                        YouTubePlayerView(videoID: embedData.videoID)
                            .frame(maxWidth: .infinity)
                            .aspectRatio(16/9, contentMode: .fit)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(HitCraftColors.border, lineWidth: 0.5)
                            )
                            .padding(.vertical, 4)
                        
                        // If there's text after the YouTube embed
                        if !embedData.textAfter.isEmpty {
                            FormattedText(text: embedData.textAfter)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 8)
                        }
                    } else {
                        // Regular Text Message with simple formatting
                        FormattedText(text: text)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if !isFromUser {
                    Spacer(minLength: 32)
                }
            }
            .padding(HitCraftLayout.messagePadding)
            .frame(maxWidth: .infinity)
            .background(isFromUser ? HitCraftColors.userMessageBackground : HitCraftColors.systemMessageBackground)
            .clipShape(RoundedRectangle(cornerRadius: HitCraftLayout.messageBubbleRadius))
            .shadow(color: Color.black.opacity(themeManager.currentTheme == .dark ? 0.3 : 0.05), radius: 2, x: 0, y: 1)
        }
        .padding(.horizontal, 8)
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
        .onAppear {
            extractYouTubeEmbed()
        }
    }
    
    // Function to extract YouTube embed data from iframe string
    private func extractYouTubeEmbed() {
        if text.contains("<iframe") && text.contains("youtube.com/embed") {
            // Extract video ID from the iframe src
            let pattern = #"youtube.com/embed/([^"?&]+)"#
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let match = regex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) {
                if let idRange = Range(match.range(at: 1), in: text) {
                    let videoID = String(text[idRange])
                    
                    // Split text into before and after iframe
                    let components = text.components(separatedBy: "<iframe")
                    let beforeIframe = components.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    
                    let afterComponents = text.components(separatedBy: "</iframe>")
                    let afterIframe = afterComponents.count > 1 ?
                                     afterComponents[1].trimmingCharacters(in: .whitespacesAndNewlines) : ""
                    
                    self.youtubeEmbedData = YouTubeEmbedData(
                        videoID: videoID,
                        textBefore: beforeIframe,
                        textAfter: afterIframe
                    )
                }
            }
        }
    }
}

// Simple view to format text without using AttributedString
struct FormattedText: View {
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(text.components(separatedBy: "\n"), id: \.self) { line in
                HStack(alignment: .top, spacing: 4) {
                    // Detect headers
                    if line.hasPrefix("### ") {
                        Text("📌")
                        Text(line.replacingOccurrences(of: "### ", with: ""))
                            .font(HitCraftFonts.poppins(16, weight: .bold))
                            .foregroundColor(HitCraftColors.text)
                    }
                    else if line.hasPrefix("## ") {
                        Text("📌")
                        Text(line.replacingOccurrences(of: "## ", with: ""))
                            .font(HitCraftFonts.poppins(16, weight: .bold))
                            .foregroundColor(HitCraftColors.text)
                    }
                    else if line.hasPrefix("# ") {
                        Text("📌")
                        Text(line.replacingOccurrences(of: "# ", with: ""))
                            .font(HitCraftFonts.poppins(16, weight: .bold))
                            .foregroundColor(HitCraftColors.text)
                    }
                    // Detect list items
                    else if line.matches(pattern: "^\\d+\\.\\s+") {
                        Text(line)
                            .font(HitCraftFonts.body())
                            .foregroundColor(HitCraftColors.text)
                    }
                    // Regular text
                    else {
                        // Replace ** with bold
                        let parts = formatBoldAndItalic(line)
                        ForEach(0..<parts.count, id: \.self) { index in
                            if parts[index].isFormatting {
                                if parts[index].isBold {
                                    Text(parts[index].text)
                                        .font(HitCraftFonts.poppins(16, weight: .bold))
                                        .foregroundColor(HitCraftColors.text)
                                } else if parts[index].isItalic {
                                    Text(parts[index].text)
                                        .font(HitCraftFonts.poppins(16, weight: .light))
                                        .italic()
                                        .foregroundColor(HitCraftColors.text)
                                } else {
                                    Text(parts[index].text)
                                        .font(HitCraftFonts.body())
                                        .foregroundColor(HitCraftColors.text)
                                }
                            } else {
                                Text(parts[index].text)
                                    .font(HitCraftFonts.body())
                                    .foregroundColor(HitCraftColors.text)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Helper function to break text into segments for formatting
    private func formatBoldAndItalic(_ text: String) -> [TextSegment] {
        var parts: [TextSegment] = []
        var currentIndex = text.startIndex
        
        // Handle bold text with **
        let boldPattern = #"\*\*(.+?)\*\*"#
        let italicPattern = #"\*(.+?)\*"#
        
        // First handle bold patterns
        if let regex = try? NSRegularExpression(pattern: boldPattern, options: []) {
            let range = NSRange(location: 0, length: text.utf16.count)
            let matches = regex.matches(in: text, options: [], range: range)
            
            if matches.isEmpty {
                parts.append(TextSegment(text: text, isFormatting: false))
            } else {
                var lastEndIndex = text.startIndex
                
                for match in matches {
                    // Add text before the match
                    if let matchRange = Range(match.range, in: text),
                       let contentRange = Range(match.range(at: 1), in: text) {
                        
                        if lastEndIndex < matchRange.lowerBound {
                            let preBoldText = text[lastEndIndex..<matchRange.lowerBound]
                            parts.append(TextSegment(text: String(preBoldText), isFormatting: false))
                        }
                        
                        // Add the bold text
                        let boldText = text[contentRange]
                        parts.append(TextSegment(text: String(boldText), isFormatting: true, isBold: true))
                        
                        lastEndIndex = matchRange.upperBound
                    }
                }
                
                // Add any remaining text
                if lastEndIndex < text.endIndex {
                    let postBoldText = text[lastEndIndex..<text.endIndex]
                    parts.append(TextSegment(text: String(postBoldText), isFormatting: false))
                }
            }
        } else {
            parts.append(TextSegment(text: text, isFormatting: false))
        }
        
        // Now handle italic patterns in each non-bold segment
        var newParts: [TextSegment] = []
        
        for part in parts {
            if !part.isFormatting {
                if let regex = try? NSRegularExpression(pattern: italicPattern, options: []) {
                    let range = NSRange(location: 0, length: part.text.utf16.count)
                    let matches = regex.matches(in: part.text, options: [], range: range)
                    
                    if matches.isEmpty {
                        newParts.append(part)
                    } else {
                        var lastEndIndex = part.text.startIndex
                        
                        for match in matches {
                            // Add text before the match
                            if let matchRange = Range(match.range, in: part.text),
                               let contentRange = Range(match.range(at: 1), in: part.text) {
                                
                                if lastEndIndex < matchRange.lowerBound {
                                    let preItalicText = part.text[lastEndIndex..<matchRange.lowerBound]
                                    newParts.append(TextSegment(text: String(preItalicText), isFormatting: false))
                                }
                                
                                // Add the italic text
                                let italicText = part.text[contentRange]
                                newParts.append(TextSegment(text: String(italicText), isFormatting: true, isItalic: true))
                                
                                lastEndIndex = matchRange.upperBound
                            }
                        }
                        
                        // Add any remaining text
                        if lastEndIndex < part.text.endIndex {
                            let postItalicText = part.text[lastEndIndex..<part.text.endIndex]
                            newParts.append(TextSegment(text: String(postItalicText), isFormatting: false))
                        }
                    }
                } else {
                    newParts.append(part)
                }
            } else {
                newParts.append(part)
            }
        }
        
        return newParts.count > 0 ? newParts : [TextSegment(text: text, isFormatting: false)]
    }
}

// Helper struct for text formatting
struct TextSegment {
    let text: String
    let isFormatting: Bool
    var isBold: Bool = false
    var isItalic: Bool = false
}

// Data structure to hold YouTube embed information
struct YouTubeEmbedData {
    let videoID: String
    let textBefore: String
    let textAfter: String
}

// Helper extension for regex matching
extension String {
    func matches(pattern: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return false
        }
        let nsRange = NSRange(self.startIndex..<self.endIndex, in: self)
        return regex.firstMatch(in: self, options: [], range: nsRange) != nil
    }
}

// Improved YouTube WebView
struct YouTubePlayerView: UIViewRepresentable {
    let videoID: String
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        
        // Set the background color based on theme
        if ThemeManager.shared.currentTheme == .dark {
            webView.backgroundColor = UIColor(HitCraftColors.systemMessageBackground)
            webView.scrollView.backgroundColor = UIColor(HitCraftColors.systemMessageBackground)
        } else {
            webView.backgroundColor = UIColor(HitCraftColors.systemMessageBackground)
            webView.scrollView.backgroundColor = UIColor(HitCraftColors.systemMessageBackground)
        }
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Build proper YouTube embed with parameters
        let embedURLString = "https://www.youtube.com/embed/\(videoID)?playsinline=1&rel=0&showinfo=0"
        
        // Create HTML with responsive video container
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
                body {
                    margin: 0;
                    padding: 0;
                    background-color: transparent;
                    overflow: hidden;
                }
                .video-container {
                    position: relative;
                    padding-bottom: 56.25%; /* 16:9 aspect ratio */
                    height: 0;
                    overflow: hidden;
                    width: 100%;
                }
                .video-container iframe {
                    position: absolute;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                    border: 0;
                }
            </style>
        </head>
        <body>
            <div class="video-container">
                <iframe src="\(embedURLString)" frameborder="0" allowfullscreen allow="autoplay; encrypted-media"></iframe>
            </div>
        </body>
        </html>
        """
        
        webView.loadHTMLString(html, baseURL: URL(string: "https://www.youtube.com"))
    }
}

struct TypingIndicator: View {
    @State private var dotOffset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(HitCraftColors.secondaryText)
                    .frame(width: 6, height: 6)
                    .offset(y: dotOffset)
                    .animation(
                        Animation.easeInOut(duration: 0.5)
                            .repeatForever()
                            .delay(0.2 * Double(index)),
                        value: dotOffset
                    )
            }
        }
        .onAppear {
            dotOffset = -5
        }
    }
}

struct ChatInput: View {
    @Binding var text: String
    let placeholder: String
    let isTyping: Bool
    let onSend: () -> Void
    
    // Send button color based on theme and state
    private var sendButtonColor: Color {
        if text.isEmpty || isTyping {
            return ThemeManager.shared.currentTheme == .dark ?
                Color.gray.opacity(0.6) : Color.gray.opacity(0.4)
        } else {
            return ThemeManager.shared.currentTheme == .dark ?
                Color.white : Color.black
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(HitCraftColors.border)
            
            VStack(spacing: 12) {
                // Input field with embedded send button
                HStack(spacing: 0) {
                    TextField(placeholder, text: $text)
                        .font(HitCraftFonts.body())
                        .padding(.leading, 16)
                        .padding(.trailing, 8)
                        .padding(.vertical, 12)
                        .foregroundColor(HitCraftColors.text)
                    
                    // Send button inside the input area
                    Button(action: onSend) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(sendButtonColor)
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(ThemeManager.shared.currentTheme == .dark ?
                                          Color.gray.opacity(0.3) : Color.gray.opacity(0.1))
                            )
                            .padding(.trailing, 12)
                    }
                    .disabled(text.isEmpty || isTyping)
                    .hitCraftStyle()
                    .scaleEffect(isTyping ? 0.95 : 1.0)
                }
                .background(HitCraftColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: HitCraftLayout.cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: HitCraftLayout.cornerRadius)
                        .stroke(HitCraftColors.border, lineWidth: 1)
                )
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 12)
            .background(HitCraftColors.headerFooterBackground)
        }
    }
}

// Helper extension for color conversion
extension UIColor {
    convenience init(_ color: Color) {
        let components = color.cgColor?.components ?? [0, 0, 0, 0]
        let red: CGFloat = components.count >= 1 ? components[0] : 0
        let green: CGFloat = components.count >= 2 ? components[1] : 0
        let blue: CGFloat = components.count >= 3 ? components[2] : 0
        let alpha: CGFloat = components.count >= 4 ? components[3] : 0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
