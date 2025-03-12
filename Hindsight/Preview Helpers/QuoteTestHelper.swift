import SwiftUI

#if DEBUG
struct QuoteDebugView: View {
    @State private var quotes: [Quote] = []
    @State private var errorMessage: String?
    
    var body: some View {
        List {
            if let error = errorMessage {
                Section("Error") {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            
            Section("Statistics") {
                Text("Total Quotes: \(quotes.count)")
                Text("Quotes with Authors: \(quotes.filter { $0.author != nil }.count)")
            }
            
            Section("All Quotes") {
                ForEach(quotes, id: \.text) { quote in
                    VStack(alignment: .leading) {
                        Text(quote.text)
                            .font(.headline)
                        if let author = quote.author {
                            Text("- \(author)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Quote Debug")
        .onAppear {
            loadQuotes()
        }
    }
    
    private func loadQuotes() {
        quotes = QuoteManager.shared.getAllQuotes()
        
        if quotes.isEmpty {
            errorMessage = "No quotes loaded! Check if quotes.json is included in the bundle."
        } else {
            errorMessage = nil
        }
    }
}

struct QuoteDebugView_Previews: PreviewProvider {
    static var previews: some View {
        QuoteDebugView()
    }
}

extension QuoteManager {
    static func verifyQuotesLoaded() -> Bool {
        !QuoteManager.shared.getAllQuotes().isEmpty
    }
    
    static func printQuoteStats() {
        let quotes = QuoteManager.shared.getAllQuotes()
        print("=== Quote System Statistics ===")
        print("Total Quotes: \(quotes.count)")
        print("Quotes with Authors: \(quotes.filter { $0.author != nil }.count)")
        print("Sample Quote: \(quotes.first?.text ?? "No quotes available!")")
        print("==========================")
    }
}
#endif 