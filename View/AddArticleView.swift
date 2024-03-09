import Foundation
import SwiftUI
import SwiftData

struct AddArticleView: View {
    @Environment(\.modelContext) private var modelContext

    @State var article: String = ""
    @State var wiki: Wiki = .English
    @Binding var isVisible: Bool
    @State var invalidArticleAlert: Bool = false

    var body: some View {
        TextField(LocalizedStringKey(stringLiteral: "Article name"), text: $article)
            .padding()
        Picker("Wiki region", selection: $wiki) {
            ForEach(Wiki.allCases) { value in
                Text(value.name())
                    .tag(value)
            }
        }
        .alert("Not a valid article", isPresented: $invalidArticleAlert) {
            Button("OK", role: .cancel) { }
        }

        Button(action: addArticle) {
            Label("Add Item", systemImage: "plus")
        }
    }

    /// Checks if article exists, if so adds it and closes view, if not, shows a popup
    private func addArticle() {
        Task {
            let exists = await pageExists(article: article, wiki: wiki)
            if exists {
                let newArticle = Article(name: article, wiki: wiki)
                await newArticle.freshRevisions()
                
                withAnimation {
                    modelContext.insert(newArticle)
                    isVisible = false
                }
                
            }
            else {
                withAnimation {
                    invalidArticleAlert = true
                }
            }
        }
    } 
}
