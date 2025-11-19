import Foundation

struct Quote: Codable {
    let text: String
    let author: String?
}

struct QuoteCollection: Codable {
    let quotes: [Quote]
}

class QuoteManager {
    static let shared = QuoteManager()
    private var allQuotes: [Quote] = []
    private var seenQuotes: Set<String> = []
    private let seenQuotesKey = "HindsightSeenQuotes"
    
    init() {
        loadQuotes()
        loadSeenQuotes()
    }
    
    private func loadQuotes() {
        // First try to load from the bundle
        if let url = Bundle.main.url(forResource: "quotes", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let quoteCollection = try decoder.decode(QuoteCollection.self, from: data)
                self.allQuotes = quoteCollection.quotes
                return
            } catch {
                print("Error loading quotes from JSON: \(error)")
            }
        }
        
        // Fallback quotes if JSON loading fails
        allQuotes = [
            Quote(text: "Rest your eyes, refresh your mind.", author: nil),
            Quote(text: "Look far to see far.", author: nil),
            Quote(text: "Take a moment to rest your eyes...", author: nil)
        ]
    }
    
    private func loadSeenQuotes() {
        if let saved = UserDefaults.standard.array(forKey: seenQuotesKey) as? [String] {
            seenQuotes = Set(saved)
        }
    }
    
    private func saveSeenQuotes() {
        UserDefaults.standard.set(Array(seenQuotes), forKey: seenQuotesKey)
    }
    
    func getRandomQuote() -> Quote {
        // Filter out quotes we've already seen
        var availableQuotes = allQuotes.filter { !seenQuotes.contains($0.text) }
        
        // If we've seen everything (or almost everything), reset
        if availableQuotes.isEmpty {
            print("All quotes seen, resetting cycle.")
            seenQuotes.removeAll()
            saveSeenQuotes()
            availableQuotes = allQuotes
        }
        
        // Fallback if something is terribly wrong (e.g. empty allQuotes)
        if availableQuotes.isEmpty {
            return Quote(text: "Breathe.", author: nil)
        }
        
        // Pick a random quote
        let quote = availableQuotes.randomElement()!
        
        // Mark as seen
        seenQuotes.insert(quote.text)
        saveSeenQuotes()
        
        #if DEBUG
        print("Quote selected: \(quote.text)")
        print("Quotes seen: \(seenQuotes.count) / \(allQuotes.count)")
        #endif
        
        return quote
    }
    
    #if DEBUG
    func getAllQuotes() -> [Quote] {
        return allQuotes
    }
    
    func resetHistory() {
        seenQuotes.removeAll()
        saveSeenQuotes()
    }
    #endif
} 