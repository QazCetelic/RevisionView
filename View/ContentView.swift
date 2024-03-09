import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var articles: [Article]
    @State private var showingAddPopup = false
    @State var path = NavigationPath()

    var body: some View {
        NavigationView {
            List {
                ForEach(articles) { article in
                    NavigationLink {
                        ArticleView(article: article, path: $path)
                            .navigationTitle(article.name)
                            .onAppear(perform: {
                                Task {
                                    await article.freshRevisions()
                                }
                            })
                    } label: {
                        Text("\(article.name)")
                            .badge(article.countUnseenRevisions())
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: { showingAddPopup = true }) {
                        Label("Add Item", systemImage: "plus")
                    }
                    .popover(isPresented: $showingAddPopup) {
                        AddArticleView(isVisible: $showingAddPopup)
                    }
                }
            }
            .navigationTitle("Articles")
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(articles[index])
            }
        }
    }

    
}

#Preview {
    ContentView()
        .modelContainer(for: Article.self, inMemory: true)
}
