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
    private var unusedQuotes: [Quote] = []
    
    #if DEBUG
    private var quoteUsageCounts: [String: Int] = [:]  // Track quote usage
    #endif
    
    init() {
        loadQuotes()
    }
    
    private func loadQuotes() {
        // First try to load from the bundle
        if let url = Bundle.main.url(forResource: "quotes", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let quoteCollection = try decoder.decode(QuoteCollection.self, from: data)
                self.allQuotes = quoteCollection.quotes
                resetUnusedQuotes()
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
        resetUnusedQuotes()
    }
    
    private func resetUnusedQuotes() {
        unusedQuotes = allQuotes.shuffled()
    }
    
    func getRandomQuote() -> Quote {
        // If we've used all quotes, reset and reshuffle
        if unusedQuotes.isEmpty {
            resetUnusedQuotes()
        }
        
        // Take the next quote from our shuffled queue
        let quote = unusedQuotes.removeLast()
        
        #if DEBUG
        // Track and print quote usage
        quoteUsageCounts[quote.text, default: 0] += 1
        print("Quote selected: \(quote.text)")
        print("Quotes remaining in current cycle: \(unusedQuotes.count)")
        print("Usage counts:")
        for (text, count) in quoteUsageCounts.sorted(by: { $0.value > $1.value }) {
            print("\"\(text)\": \(count) times")
        }
        #endif
        
        return quote
    }
    
    #if DEBUG
    // Helper method to verify quotes are loaded
    func getAllQuotes() -> [Quote] {
        return allQuotes
    }
    #endif
} 