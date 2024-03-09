import Foundation
import SwiftUI
import SwiftData

struct ArticleView: View {
    @Bindable var article: Article
    @Binding var path: NavigationPath

    var body: some View {
        Text("Wikipedia \(article.wiki.name())")
            .font(.title2)
        Text("Following since \(article.added, format: Date.FormatStyle(date: .numeric, time: .standard)). Updated at \(article.reloaded, format: Date.FormatStyle(date: .numeric, time: .standard)).")
            .padding()
        HStack {
            Button(action: {
                Task {
                    await article.loadRevisions()
                }
            }, label: {
                Text("Refresh now")
            })
            Button(action: {
                article.setAllRevisionRead(to: true)
            }, label: {
                Text("Mark all as read")
            })
            Button(action: {
                article.setAllRevisionRead(to: false)
            }, label: {
                Text("Mark all as unread")
            })
        }
        
        TextField(LocalizedStringKey(stringLiteral: "Notes"), text: $article.notes, axis: .vertical)
            .padding()
        List {
            ForEach(article.chronologicalRevisions) { revision in
                NavigationLink {
                    RevisionView(revision: revision)
                        .navigationTitle("\(revision.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                        .onAppear {
                            revision.seen = true
                        }
                } label: {
                    let label = Text("\(revision.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard)) \(revision.user)")
                    if !revision.seen {
                        label.bold()
                    }
                    else {
                        label
                    }
                }
            }
        }
    }
}
