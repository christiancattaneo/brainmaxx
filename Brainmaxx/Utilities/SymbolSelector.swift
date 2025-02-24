import Foundation

/// Utility for automatically selecting appropriate SF Symbols for subjects
struct SymbolSelector {
    // MARK: - Category Matching
    
    /// Maps keywords to relevant SF Symbol names
    private static let categorySymbols: [String: String] = [
        // Academic subjects
        "math": "function",
        "algebra": "function",
        "calculus": "function",
        "geometry": "shape.3d.badge.3d",
        "statistics": "chart.bar",
        "trigonometry": "function",
        
        // Sciences
        "physics": "atom",
        "quantum": "atom",
        "chemistry": "flask",
        "biology": "leaf",
        "anatomy": "heart",
        "genetics": "dna",
        "astronomy": "star",
        "space": "star",
        "geology": "mountain.2",
        "environment": "globe.europe.africa",
        
        // Humanities
        "history": "clock.fill",
        "ancient": "building.columns",
        "medieval": "scroll",
        "century": "clock.fill",
        "war": "shield",
        "revolution": "flag",
        "philosophy": "brain.head.profile",
        
        // Languages & Literature
        "language": "textformat",
        "literature": "book.fill",
        "grammar": "text.quote",
        "writing": "pencil",
        "poetry": "text.book.closed",
        "english": "textformat",
        "spanish": "textformat",
        "french": "textformat",
        "german": "textformat",
        "chinese": "textformat",
        "japanese": "textformat",
        
        // Geography & Social Studies
        "geography": "globe.americas.fill",
        "countries": "globe.americas.fill",
        "continent": "globe.americas.fill",
        "sociology": "person.3",
        "psychology": "brain",
        "economics": "chart.line.uptrend.xyaxis",
        "political": "building.columns",
        "government": "building",
        
        // Arts
        "art": "paintpalette",
        "music": "music.note",
        "film": "film",
        "cinema": "film",
        "theater": "theatermasks.fill",
        "dance": "figure.dance",
        "painting": "paintbrush",
        "design": "pencil.and.ruler",
        
        // Technology
        "computer": "desktopcomputer",
        "programming": "chevron.left.forwardslash.chevron.right",
        "coding": "chevron.left.forwardslash.chevron.right",
        "software": "laptopcomputer",
        "hardware": "cpu",
        "artificial intelligence": "brain.head.profile",
        "ai": "brain.head.profile",
        "network": "network",
        "technology": "gear",
        
        // Miscellaneous
        "sports": "figure.run",
        "health": "heart.text.square",
        "nutrition": "fork.knife",
        "cooking": "cooktop",
        "business": "briefcase"
    ]
    
    // Words that are less important in compound subjects (usually modifiers or generic terms)
    private static let lowPriorityWords = Set([
        "introduction", "basics", "fundamentals", "advanced", "intermediate", "beginner",
        "principles", "concepts", "theory", "practice", "applied", "modern", "contemporary",
        "study", "studies", "basic", "intro", "practical", "theoretical", "guide", "tutorial",
        "course", "class", "lesson", "workshop", "seminar", "fundamentals", "foundations"
    ])
    
    // MARK: - First Letter Matching
    
    /// Gets a symbol based on the first letter of the subject
    private static func symbolFromFirstLetter(_ subject: String) -> String {
        guard let firstChar = subject.lowercased().first else {
            return "sparkles.rectangle.stack"
        }
        
        switch firstChar {
        case "a"..."c": return "book.fill"
        case "d"..."f": return "function" 
        case "g"..."i": return "globe.americas.fill"
        case "j"..."l": return "leaf"
        case "m"..."o": return "atom"
        case "p"..."r": return "paintpalette"
        case "s"..."u": return "clock.fill"
        case "v"..."z": return "textformat"
        default: return "sparkles.rectangle.stack"
        }
    }
    
    // MARK: - OpenAI Symbol Suggestion
    
    /// Gets a symbol suggestion from OpenAI
    static func getSymbolFromOpenAI(for subject: String, availableSymbols: [String]) async -> String? {
        do {
            let customPrompt = "For the subject '\(subject)', suggest the most appropriate Apple SF Symbol name. Reply only with the exact SF Symbol name, nothing else. Choose only from this list: \(availableSymbols.joined(separator: ", "))"
            
            // Use the most basic prompt possible to encourage a direct, simple response
            if let aiSuggestion = try await OpenAIService.shared.getSimpleResponse(prompt: customPrompt) {
                // Clean up the response - remove quotes, spaces, etc.
                let cleanedSuggestion = aiSuggestion
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: "\"", with: "")
                    .replacingOccurrences(of: "'", with: "")
                
                // Check if the suggested symbol is in our available list
                if availableSymbols.contains(cleanedSuggestion) {
                    print("📊 SymbolSelector: OpenAI suggested '\(cleanedSuggestion)' for '\(subject)'")
                    return cleanedSuggestion
                } else {
                    print("📊 SymbolSelector: OpenAI suggested '\(cleanedSuggestion)' but it's not in the available list")
                }
            }
        } catch {
            print("📊 SymbolSelector: Error getting OpenAI suggestion: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    // MARK: - Category-Based Matching
    
    /// Finds the most relevant symbol by checking for keywords in the subject
    private static func findSymbolForSubject(_ subject: String) -> String {
        let lowercased = subject.lowercased()
        
        // Try exact matches first
        if let exactMatch = categorySymbols[lowercased] {
            print("📊 SymbolSelector: Exact match for '\(lowercased)'")
            return exactMatch
        }
        
        // Split into words and remove low priority words
        let words = lowercased.split(separator: " ").map(String.init)
        
        // Filter out low priority words for high-priority matching
        let highPriorityWords = words.filter { !lowPriorityWords.contains($0) }
        
        // If we have high priority words, try matching those first
        if !highPriorityWords.isEmpty {
            for word in highPriorityWords {
                if let match = categorySymbols[word] {
                    print("📊 SymbolSelector: High-priority word match for '\(word)'")
                    return match
                }
            }
            
            // Try word pairs with high priority words
            if highPriorityWords.count >= 2 {
                for i in 0..<(highPriorityWords.count-1) {
                    let wordPair = highPriorityWords[i] + " " + highPriorityWords[i+1]
                    if let match = categorySymbols[wordPair] {
                        print("📊 SymbolSelector: High-priority word pair match for '\(wordPair)'")
                        return match
                    }
                }
            }
        }
        
        // Try all words as fallback
        for word in words {
            if let match = categorySymbols[word] {
                print("📊 SymbolSelector: Individual word match for '\(word)'")
                return match
            }
        }
        
        // Try word pairs for multi-word subjects (more specific matches)
        if words.count >= 2 {
            for i in 0..<(words.count-1) {
                let wordPair = words[i] + " " + words[i+1]
                if let match = categorySymbols[wordPair] {
                    print("📊 SymbolSelector: Word pair match for '\(wordPair)'")
                    return match
                }
            }
        }
        
        // Then try partial matches (less specific)
        // Sort the keywords by length (descending) to prefer longer, more specific matches
        let sortedKeywords = categorySymbols.keys.sorted { $0.count > $1.count }
        
        for keyword in sortedKeywords {
            if lowercased.contains(keyword) {
                print("📊 SymbolSelector: Partial keyword match for '\(keyword)'")
                return categorySymbols[keyword]!
            }
        }
        
        print("📊 SymbolSelector: No category match found for '\(subject)'")
        return "sparkles.rectangle.stack" // Default symbol
    }
    
    // MARK: - Hybrid Approach
    
    /// Selects the best symbol for a subject using multiple methods
    static func selectSymbol(for subject: String) -> String {
        // Use the synchronous version by default, which doesn't include OpenAI
        return selectSymbolSync(for: subject)
    }
    
    /// Synchronous version of the symbol selector (no AI)
    static func selectSymbolSync(for subject: String) -> String {
        // Step 1: Try category matching first
        let categorySymbol = findSymbolForSubject(subject)
        if categorySymbol != "sparkles.rectangle.stack" {
            print("📊 SymbolSelector: Found category match '\(categorySymbol)' for '\(subject)'")
            return categorySymbol
        }
        
        // Step 2: Fall back to first letter matching
        let letterSymbol = symbolFromFirstLetter(subject)
        print("📊 SymbolSelector: Using first letter match '\(letterSymbol)' for '\(subject)'")
        return letterSymbol
    }
    
    /// Asynchronous symbol selector that includes OpenAI suggestions
    static func selectSymbolAsync(for subject: String, availableSymbols: [String]) async -> String {
        // Step 1: Try OpenAI first if the subject is substantial enough
        if subject.count > 3 {
            if let aiSymbol = await getSymbolFromOpenAI(for: subject, availableSymbols: availableSymbols) {
                return aiSymbol
            }
        }
        
        // Step 2: Fall back to our regular hybrid approach
        return selectSymbolSync(for: subject)
    }
} 